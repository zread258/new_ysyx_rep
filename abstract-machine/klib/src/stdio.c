#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

int printf(const char *fmt, ...) {
  char buf[1024];
  memset(buf, 0, sizeof(buf));
  va_list ap;
  va_start(ap, fmt);
  int ret = vsprintf(buf, fmt, ap);
  va_end(ap);
  for (int i = 0; buf[i] != '\0'; i++) {
    putch(buf[i]);
  }
  return ret;
}

int vsprintf(char *out, const char *fmt, va_list ap) {
  char *p = out;
  bool is_long = false;
  for (; *fmt; fmt++) {
    if (*fmt != '%') {
      *p++ = *fmt;
      continue;
    }
    fmt++;
    if (*fmt == 'l') {
      is_long = true;
      fmt++;
    }
    switch (*fmt) {
      case 'd': {
        long num;
        if (is_long) {
          num = va_arg(ap, long);
        } else {
          num = va_arg(ap, int);
        }
        if (num < 0) {
          *p++ = '-';
          num = -num;
        }
        char buf[32];
        int len = 0;
        do {
          buf[len++] = num % 10 + '0';
          num /= 10;
        } while (num);
        for (int i = len - 1; i >= 0; i--) {
          *p++ = buf[i];
        }
        break;
      }
      case 's': {
        char *str = va_arg(ap, char *);
        while (*str) {
          *p++ = *str++;
        }
        break;
      }
      case 'c': {
        char ch = va_arg(ap, int);
        *p++ = ch;
        break;
      }
      case 'x': {
        unsigned int num = va_arg(ap, int);
        char buf[32];
        int len = 0;
        do {
          int digit = num % 16;
          if (digit < 10) {
            buf[len++] = digit + '0';
          } else {
            buf[len++] = digit - 10 + 'a';
          }
          num /= 16;
        } while (num);
        for (int i = len - 1; i >= 0; i--) {
          *p++ = buf[i];
        }
        break;
      }
      case '%': {
        *p++ = '%';
        break;
      }
      default: {
        *p++ = '%';
        *p++ = *fmt;
        break;
      }
    }
  }
  *p = '\0';
  return p - out;
}

int sprintf(char *out, const char *fmt, ...) {
  va_list ap;
  va_start(ap, fmt);
  int ret = vsprintf(out, fmt, ap);
  va_end(ap);
  return ret;
}

int snprintf(char *out, size_t n, const char *fmt, ...) {
  panic("Not implemented");
}

int vsnprintf(char *out, size_t n, const char *fmt, va_list ap) {
  panic("Not implemented");
}

#endif
