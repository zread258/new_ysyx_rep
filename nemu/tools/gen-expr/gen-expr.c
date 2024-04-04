/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <assert.h>
#include <string.h>

// this should be enough
static char buf[65536] = {};
static char code_buf[65536 + 128] = {}; // a little larger than `buf`
static char *code_format =
"#include <stdio.h>\n"
"int main() { "
"  unsigned result = %s; "
"  printf(\"%%u\", result); "
"  return 0; "
"}";

uint32_t choose(uint32_t n) {
  return (uint32_t)(rand() % n);
}

int cnt = 0;

void gen_rand_spaces() {
  int n = choose(4);
  while (n--) buf[cnt++] = ' ';
}

static void gen_rand_expr(int* success) {
  switch (choose(3)) {
    case 0: gen_rand_spaces(success);
            buf[cnt++] = '0' + choose(10); 
            if (cnt >= 1000) {
              *success = 0;
              return;
            }
            gen_rand_spaces(success); 
            break;
    case 1: // gen_rand_spaces(); 
            buf[cnt++] = '('; 
            // gen_rand_spaces();
            gen_rand_expr(success); 
            // gen_rand_spaces();
            buf[cnt++] = ')';
            if (cnt >= 1000) {
              *success = 0;
              return;
            }
            // gen_rand_spaces();
            break;
    default: 
              // gen_rand_spaces();
              gen_rand_expr(success); 
              // gen_rand_spaces();
              // gen_rand_op();
              switch (choose(4))
              {
              case 0: buf[cnt++] = '+'; break;
              case 1: buf[cnt++] = '-'; break;
              case 2: buf[cnt++] = '*'; break;
              case 3: buf[cnt++] = '/'; break;
              default:
                break;
              } 
              if (cnt >= 1000) {
                *success = 0;
                return;
              }
              // gen_rand_spaces();
              gen_rand_expr(success); 
              // gen_rand_spaces();
              break;
  }
}

int main(int argc, char *argv[]) {
  int seed = time(0);
  srand(seed);
  int loop = 1;
  if (argc > 1) {
    sscanf(argv[1], "%d", &loop);
  }
  int i;
  for (i = 0; i < loop; i ++) {

    for (int j = 0; j < cnt; j++) {
      buf[j] = '\0';
    }

    cnt = 0;

    int success = 1;

    gen_rand_expr(&success);

    if (!success) {
      i--;
      continue;
    }

    sprintf(code_buf, code_format, buf);

    FILE *fp = fopen("/tmp/.code.c", "w");
    assert(fp != NULL);
    fputs(code_buf, fp);
    fclose(fp);

    int ret = system("gcc /tmp/.code.c -o /tmp/.expr > ./.log.txt 2>&1");
    if (ret != 0) continue;

    FILE *log = fopen("./.log.txt", "r");
    assert(log != NULL);
    char line[1024];
    int flag = 0;
    while (fgets(line, sizeof(line), fp)) {
        if (strstr(line, "division by zero") != NULL) {
            flag = 1;
            break;
        }
    }
    if (flag) {
      i--;
      continue;
    }

    fp = popen("/tmp/.expr", "r");
    assert(fp != NULL);

    int result;
    ret = fscanf(fp, "%d", &result);
    pclose(fp);

    printf("%u %s\n", result, buf);
  }
  return 0;
}
