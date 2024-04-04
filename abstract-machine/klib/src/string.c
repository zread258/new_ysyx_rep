#include <klib.h>
#include <klib-macros.h>
#include <stdint.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

size_t strlen(const char *s) {
  size_t i = 0;
  while (s[i] != '\0') {
    i++;
  }
  return i;
}

char *strcpy(char *dst, const char *src) {
  size_t i = 0;
  while (src[i] != '\0') {
    dst[i] = src[i];
    i++;
  }
  dst[i] = '\0';
  return dst;
}

char *strncpy(char *dst, const char *src, size_t n) {
  for (int i = 0; i < n; i++) {
    dst[i] = src[i];
    if (src[i] == '\0') {
      break;
    }
  }
  return dst;
}

char *strcat(char *dst, const char *src) {
  int src_len = strlen(src);
  int dst_len = strlen(dst);
  for (int i = 0; i < src_len; i++) {
    dst[dst_len + i] = src[i];
  }
  return dst;
}

int strcmp(const char *s1, const char *s2) {
  int i = 0;
  while (s1[i] != '\0' && s2[i] != '\0') {
    if (s1[i] != s2[i]) {
      return s1[i] - s2[i];
    }
    i++;
  }
  return s1[i] - s2[i];
}

int strncmp(const char *s1, const char *s2, size_t n) {
  int i = 0;
  while (i < n && s1[i] != '\0' && s2[i] != '\0') {
    if (s1[i] != s2[i]) {
      return s1[i] - s2[i];
    }
    i++;
  }
  if (i == n) {
    return 0;
  }
  return s1[i] - s2[i];
}

void *memset(void *s, int c, size_t n) {
  for (int i = 0; i < n; i++) {
    ((char*)s)[i] = c;
  }
  return s;
}

void *memmove(void *dst, const void *src, size_t n) {
  for (int i = 0; i < n; i++) {
    ((char*)dst)[i] = ((char*)src)[i];
  }
  return dst;
}

void *memcpy(void *out, const void *in, size_t n) {
  for (int i = 0; i < n; i++) {
    ((char*)out)[i] = ((char*)in)[i];
  }
  return out;
}

int memcmp(const void *s1, const void *s2, size_t n) {
  for (int i = 0; i < n; i++) {
    if (((char*)s1)[i] != ((char*)s2)[i]) {
      return ((char*)s1)[i] - ((char*)s2)[i];
    }
  }
  return 0;
}

#endif
