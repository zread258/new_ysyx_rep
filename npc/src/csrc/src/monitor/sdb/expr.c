/***************************************************************************************
 * Copyright (c) 2014-2022 Zihao Yu, Nanjing University
 *
 * NEMU is licensed under Mulan PSL v2.
 * You can use this software according to the terms and conditions of the Mulan
 *PSL v2. You may obtain a copy of Mulan PSL v2 at:
 *          http://license.coscl.org.cn/MulanPSL2
 *
 * THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY
 *KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
 *NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
 *
 * See the Mulan PSL v2 for more details.
 ***************************************************************************************/

#include <isa.h>

/* We use the POSIX regex functions to process regular expressions.
 * Type 'man regex' for more information about POSIX regex functions.
 */
#include <assert.h>
#include <debug.h>
#include <regex.h>
#include <stdlib.h>
#include <string.h>
#include <memory/paddr.h>

// word_t vaddr_read(vaddr_t addr, int len);
word_t isa_reg_str2val(const char *s, bool *success);
word_t get_curpc();
word_t paddr_read(word_t addr, int len);

enum {
  TK_NOTYPE = 256,
  TK_EQ,
  TK_INT,
  TK_LEFT,
  TK_RIGHT,
  TK_NEQ,
  TK_AND,
  TK_REG,
  TK_DEREF,
  TK_HEX,
  TK_GE,
  TK_LE,
  TK_LT,
  TK_GT,
  TK_SHL,
  TK_SHR,
  TK_ADDR,
  TK_BWA,
  TK_BWN,
  TK_BWO,
  TK_NEG
};

static struct rule {
  const char *regex;
  int token_type;
} rules[] = {

    {" +", TK_NOTYPE}, // spaces
    {"\\+", '+'},      // plus
    {"==", TK_EQ},     // equal
    {"\\-", '-'},
    {"\\*", '*'},
    {"\\/", '/'},
    {"\\$[a-zA-Z0-9$]+", TK_REG},
    {"0x[0-9a-fA-F]+", TK_HEX},
    {"[0-9]+", TK_INT},
    {"\\(", TK_LEFT},
    {"\\)", TK_RIGHT},
    {"!=", TK_NEQ},
    {"&&", TK_AND},
    {">=", TK_GE},
    {"<=", TK_LE},
    {"<<", TK_SHL},
    {">>", TK_SHR},
    {"<", TK_LT},
    {">", TK_GT},
    {"&", TK_BWA}, // Bit Wise And
    {"\\|", TK_BWO}, // Bit Wise Or
    {"!", TK_BWN}  // Bit Wise Not

};

#define NR_REGEX ARRLEN(rules)
#define First_Stage_Operand(i)                                                 \
  tokens[i].type == '+' || tokens[i].type == '-' || tokens[i].type == TK_EQ || \
      tokens[i].type == TK_NEQ || tokens[i].type == TK_AND ||                  \
      tokens[i].type == TK_GE || tokens[i].type == TK_LE ||                    \
      tokens[i].type == TK_SHL || tokens[i].type == TK_SHR ||                  \
      tokens[i].type == TK_LT || tokens[i].type == TK_GT ||                    \
      tokens[i].type == TK_BWA || tokens[i].type == TK_BWO                     \
      
#define Second_Stage_Operand(i) \
  tokens[i].type == '*' || tokens[i].type == '/' || tokens[i].type == TK_NEG
#define Third_Stage_Operand(i) \
  tokens[i].type == TK_BWN
#define Certain_TYPE(i) \
  (tokens[i].type != TK_INT && tokens[i].type != TK_HEX && tokens[i].type != TK_REG)

static regex_t re[NR_REGEX] = {};

/* Rules are used for many times.
 * Therefore we compile them only once before any usage.
 */
void init_regex() {
  int i;
  char error_msg[128];
  int ret;

  for (i = 0; i < NR_REGEX; i++) {
    ret = regcomp(&re[i], rules[i].regex, REG_EXTENDED);
    if (ret != 0) {
      // regerror(ret, &re[i], error_msg, 128);
      // panic("regex compilation failed: %s\n%s", error_msg, rules[i].regex);
    }
  }
}

typedef struct token {
  int type;
  char str[32];
} Token;

static Token tokens[1024] __attribute__((used)) = {};
static int nr_token __attribute__((used)) = 0;

void push_back_to_tokens(Token *tokens, int type, char *substr_start,
                         int substr_len, int *cnt) {
  strncpy(tokens[*cnt].str, substr_start, substr_len);
  tokens[*cnt].type = type;
  *cnt = *cnt + 1;
}

static bool make_token(char *e) {
  int position = 0;
  int i;
  regmatch_t pmatch;

  nr_token = 0;

  int cnt = 0;

  while (e[position] != '\0') {
    /* Try all rules one by one. */
    for (i = 0; i < NR_REGEX; i++) {
      if (regexec(&re[i], e + position, 1, &pmatch, 0) == 0 &&
          pmatch.rm_so == 0) {
        char *substr_start = e + position;
        int substr_len = pmatch.rm_eo;

        position += substr_len;

        if (i != 0)
          push_back_to_tokens(tokens, rules[i].token_type, substr_start,
                              substr_len, &cnt);

        break;
      }
    }

    nr_token = cnt;

    if (i == NR_REGEX) {
      printf("no match at position %d\n%s\n%*.s^\n", position, e, position, "");
      return false;
    }
  }

  return true;
}

bool check_parentheses(int p, int q) {
  if (tokens[p].type != TK_LEFT) {
    return false;
  }
  int count = 1;
  for (int i = p + 1; i <= q; i++) {
    if (count == 0) {
      return false;
    }
    if (tokens[i].type == TK_LEFT) {
      count++;
    } else if (tokens[i].type == TK_RIGHT) {
      count--;
    }
  }
  if (count == 0) {
    return true;
  }
  return false;
}

void op_update(int i, int *op, int *count, int *now) {
  *op = i;
  *now = *count;
}

sword_t eval(int p, int q) {
  if (p > q) {
    /* Bad expression */
    // Assert(p <= q, "Bad Program!!! p = %d, q = %d, now p > q!", p, q);
    return 0;
  } else if (p == q) {
    /* Single token.
     * For now this token should be a number.
     * Return the value of the number.
     */
    sword_t val;
    bool success;
    switch (tokens[p].type) {
    case TK_INT:
      val = strtol(tokens[p].str, NULL, 10);
      memset(tokens[p].str, '\0', sizeof(tokens[p].str));
      return val;
      break;
    case TK_HEX:
      val = strtol(tokens[p].str, NULL, 16);
      memset(tokens[p].str, '\0', sizeof(tokens[p].str));
      return val;
      break;
    case TK_REG:
      if (strcmp(tokens[p].str, "$pc") == 0) {
        return get_curpc();
      }
      success = false;
      val = isa_reg_str2val(tokens[p].str + 1, &success);
      if (!success) {
        Assert(success, "Register %s not exists!", tokens[p].str + 1);
      }
      return val;
      break;
    default:
      break;
    }
  } else if (check_parentheses(p, q) == true) {
    /* The expression is surrounded by a matched pair of parentheses.
     * If that is the case, just throw away the parentheses.
     */
    return eval(p + 1, q - 1);
  } else {
    int op = -1;
    int count_parentheses = 0, now_parentheses = 100;
    for (int i = p; i <= q; i++) {
      if (tokens[i].type == TK_LEFT) {
        count_parentheses++;
      } else if (tokens[i].type == TK_RIGHT) {
        count_parentheses--;
      } else if (First_Stage_Operand(i)) {
        if (now_parentheses >= count_parentheses) {
          op_update(i, &op, &count_parentheses, &now_parentheses);
        }
        continue;
      } else if (Second_Stage_Operand(i)) {
        if (now_parentheses == count_parentheses) {
          if (First_Stage_Operand(op)) {
            continue;
          } else {
            op_update(i, &op, &count_parentheses, &now_parentheses);
          }
        } else if (now_parentheses > count_parentheses) {
          op_update(i, &op, &count_parentheses, &now_parentheses);
        }
      } else if (Third_Stage_Operand(i)) {
        if (now_parentheses == count_parentheses) {
          if (First_Stage_Operand(op) || Second_Stage_Operand(op)) {
            continue;
          } else {
            op_update(i, &op, &count_parentheses, &now_parentheses);
          }
        } else if (now_parentheses > count_parentheses) {
          op_update(i, &op, &count_parentheses, &now_parentheses);
        }
      } else if (tokens[i].type == TK_DEREF) {
        if (now_parentheses == count_parentheses) {
          if (Second_Stage_Operand(op) || First_Stage_Operand(op)) {
            continue;
          } else {
            op_update(i, &op, &count_parentheses, &now_parentheses);
          }
        } else if (now_parentheses > count_parentheses) {
          op_update(i, &op, &count_parentheses, &now_parentheses);
        }
      }
    }

    sword_t val1 = eval(p, op - 1);
    sword_t val2 = eval(op + 1, q);

    switch (tokens[op].type) {
    case '+':
      return val1 + val2;
      break;
    case '-':
      return val1 - val2;
      break;
    case '*':
      return val1 * val2;
      break;
    case '/':
      return val1 / val2;
      break;
    case TK_EQ:
      return val1 == val2;
      break;
    case TK_NEQ:
      return val1 != val2;
      break;
    case TK_AND:
      return val1 && val2;
      break;
    case TK_BWA:
      return val1 & val2;
      break;
    case TK_BWN:
      return !val2;
      break;
    case TK_BWO:
      return val1 | val2;
      break;
    case TK_GE:
      return val1 >= val2;
      break;
    case TK_LE:
      return val1 <= val2;
      break;
    case TK_SHL:
      return val1 << val2;
      break;
    case TK_SHR:
      return val1 >> val2;
      break;
    case TK_LT:
      return val1 < val2;
      break;
    case TK_GT:
      return val1 > val2;
      break;
    case TK_NEG:
      return -val2;
      break;
    /*
    ToDo: Complement '&' Get Addr Operator
    case TK_ADDR:
      return ;
      break;
    */
    case TK_DEREF:
      // return paddr_read(val2, 4);
      break;
    default:
      assert(0);
    }
  }
  return 0;
}

sword_t expr(char *e, bool *success) {
  if (!make_token(e)) {
    *success = false;
    return 0;
  }

  for (int i = 0; i < nr_token; i++) {
    if (tokens[i].type == '*' && (i == 0 || Certain_TYPE(i - 1))) {
      tokens[i].type = TK_DEREF;
    }
    if (tokens[i].type == '-' && (i == 0 || Certain_TYPE(i - 1))) {
      tokens[i].type = TK_NEG;
    }
    /*
    ToDo: Above
    if (tokens[i].type == '&' &&
        (i == 0 || tokens[i - 1].type != TK_INT)) {
          tokens[i].type = TK_ADDR;
        }
    */
  }

  sword_t result = eval(0, nr_token - 1);
  *success = true;

  return result;
}
