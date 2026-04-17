// RUN: %clang_cc1 -std=c++20 -verify %s

struct A1 {
  int x;
  void f() { x = 1; } // OK
};

struct Base {
  int y;
};
struct Derived : Base {
  void f() { y = 2; } // OK
};

struct A2 { int z; };
struct B2 : A2 {
  using A2::z;
  void f() { z = 3; } // OK
};

void pass1() {
  struct A { struct B {}; };
  A::B b; // OK
}

void pass2() {
  class A { public: class B; };
  class A::B {};
  A::B b; // OK
}

void fail1() {
  class A { public: class B; };
  class A::B {};
  B b; // expected-error {{'B'}}
}

template<class T>
struct Wrapper { Wrapper(T) {} };

void fail2() {
  class A { public: class B; };
  class A::B {};
  Wrapper w = Wrapper{B{}}; // expected-error {{'B'}}
}

void fail3() {
  struct A { public: struct B; };
  struct A::B {};
  B b; // expected-error {{'B'}}
}
