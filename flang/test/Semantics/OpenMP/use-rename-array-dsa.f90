! RUN: %python %S/../test_errors.py %s %flang_fc1 -fopenmp

! Check that compiling a USE-renamed array inside an OpenMP construct
! does not trigger a dimension mismatch error against the original symbol name.
! Also serves as a check that host-association for implicitly scoped variables
! links against the local 'use' alias symbol correctly.

module mod1
  implicit none
  real(8), allocatable :: ary(:,:,:)
end module mod1

module mod2
  implicit none
  real(8), allocatable :: ary(:,:,:,:,:)
end module mod2

module mod3
  implicit none
contains
  subroutine sub(arg)
    use mod1, only: s_ary => ary
    use mod2, only: ary
    implicit none
    integer(4), intent(in) :: arg
    integer(4) :: i, j, k
    integer(4) :: xx, yy, zs, ze, mm

    !$omp parallel do
    do j = 0, yy+1
      do i = 0, xx+1
        do k = zs, ze
          s_ary(k,i,j) = s_ary(k,i,j) + ary(k,-1,i,j,mm)
          ary(k,-1,i,j,mm) = 0._8
        end do
      end do
    end do
    !$omp end parallel do
  end subroutine sub
end module mod3
