// RUN: %clang_cc1 -std=c++2c -fsyntax-only -verify %s
// RUN: %clang_cc1 -fexperimental-new-constant-interpreter -std=c++2c -fsyntax-only -verify %s


namespace std {
  using size_t = decltype(sizeof(0));
  template<typename> struct tuple_size;
  template<size_t, typename> struct tuple_element;
}

struct Pinned {
  Pinned(const Pinned&) = delete; 
  // expected-note@-1 {{'Pinned' has been explicitly marked deleted here}}
  Pinned& operator=(const Pinned&) = delete;
};

struct Source {
  operator Pinned&&() const;
  
  template<std::size_t>
  Source get() noexcept;
};

template<>
struct std::tuple_size<Source> {
  static constexpr std::size_t value = 1;
};

template<>
struct std::tuple_element<0, Source> { using type = Pinned; };

// CWG3135: In C++26 mode `x` is of type Pinned rather than Pinned&&. 
// This leads to the deleted copy ctor being called in C++26 mode.
auto [x] = Source{};
// expected-error-re@-1 {{call to deleted constructor of 'std::tuple_element<0U{{L*}}, Source>::type' (aka 'Pinned')}}
// expected-note@-2 {{in implicit initialization of binding declaration 'x'}}
