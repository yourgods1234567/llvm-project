// RUN: %clang_cc1 -fsyntax-only -verify=expected -Wbool-integral-comparison %s
// RUN: %clang_cc1 -fsyntax-only -verify=expected -Wextra %s
// RUN: %clang_cc1 -fsyntax-only -verify=expected,priority -Wbool-integral-comparison -Wtautological-unsigned-zero-compare %s
// RUN: %clang_cc1 -fsyntax-only -verify=wall -Wall %s

// wall-no-diagnostics

void integral_comparisons(bool b, char c, int i, unsigned u, bool other) {
  (void)(b == c); // expected-warning {{comparison between 'bool' and integral type 'char' is suspicious; the 'bool' operand is converted to an integral value that can only be 0 or 1}}
  (void)(c != b); // expected-warning {{comparison between 'bool' and integral type 'char' is suspicious; the 'bool' operand is converted to an integral value that can only be 0 or 1}}
  (void)(b < i);  // expected-warning {{comparison between 'bool' and integral type 'int' is suspicious; the 'bool' operand is converted to an integral value that can only be 0 or 1}}
  (void)(u >= b); // expected-warning {{comparison between 'bool' and integral type 'unsigned int' is suspicious; the 'bool' operand is converted to an integral value that can only be 0 or 1}}

  (void)(b == other);
}

void no_warning_for_constant_integral(bool b) {
  constexpr int one = 1;
  const int zero = 0;

  (void)(b == 1);
  (void)(0 != b);
  (void)(b < one);
  (void)(zero >= b);
  (void)(true >= 'a');
}

enum E { e0, e1 };

void enum_comparisons(bool b, E e) {
  (void)(b == e); // expected-warning {{comparison between 'bool' and enumeration type 'E' is suspicious; the 'bool' operand is converted to an integral value that can only be 0 or 1}}
  (void)(e != b); // expected-warning {{comparison between 'bool' and enumeration type 'E' is suspicious; the 'bool' operand is converted to an integral value that can only be 0 or 1}}
}

void no_warning_for_constant_enum(bool b) {
  constexpr E zero = e0;
  const E one = e1;

  (void)(b == e0);
  (void)(e1 != b);
  (void)(b == zero);
  (void)(one != b);
}

void tautological_compare_priority(unsigned u) {
  (void)(false <= u); // priority-warning {{comparison of 0 <= unsigned expression is always true}}
  (void)(u >= false); // priority-warning {{comparison of unsigned expression >= 0 is always true}}
}
