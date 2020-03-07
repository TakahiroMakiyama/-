!----------------------------------------------------------
!���[���ω�����ꍇ�̒Ôg�̉^���������ߎ����ŉ���
!----------------------------------------------------------
implicit none
!�ϐ��̌^�錾 --------------------------------------
integer,parameter::iq=988
real*8:: uf(iq), up(iq), ub(iq)         !�����Bf,p,b�͂��ꂼ�ꖢ���C���݁C�ߋ��ɑΉ��B
real*8:: zf(iq+1), zp(iq+1), zb(iq+1)   !�C�\�ʕψ�
real*8:: x(iq+1), depth(iq+1)
real*8:: grav, time_end, time_out, dx,&
         dt, eps, depth0, depth1
integer:: i, n, nend, nout, index
!
! �p�����[�^�̐ݒ� -------------------------
grav=9.8              !�d�͉����x[m/s^2]
time_end=3.*60.*60.   !�v�Z����[s]
time_out=60.          !�f�[�^�o�͎��ԊԊu[s]
! ���[�f�[�^�̓ǂݍ��� ---------------------
open(10,file="DEPTH.data")
!
do i=1,iq+1
 read(10,*) x(i), depth(i)  !x[km]�݂͊���̋����B���[�̕����̓}�C�i�X�B
     depth(i)=-depth(i)
         x(i)=x(i)*1000.    !�P�ʂ��L�����烁�[�g����
 enddo
! �T�C�Y�ݒ� --------------------------------
dx=(x(iq+1)-x(1))/iq  !��ԃO���b�h�T�C�Y
dt=0.5                ! ���ԃX�e�b�v�T�C�Y
! �����l�̐ݒ� ------------------------------      
do i=1,iq
up(i)=0.
enddo
 do i=1,iq+1
 zp(i)=-2.*exp(-dble(x(i)-115.*1000.)**2/dble(40.*1000.)**2)&   ! �����g�̏����l�ix=115km��-2m�̒��~���j 
       +5.*exp(-dble(x(i)-215.*1000.)**2/dble(40.*1000.)**2)    ! �����g�̏����l�ix=215km��+5m�̗��N���j 
! �Ôg�̏����l�́A���y�n���@�����肵���C��n�`�̗��N�E���~���z�����K���g���ēǂݎ���ė^����B
! http://www.gsi.go.jp/common/000060406.pdf 
enddo
!
! �o�̓f�[�^�t�@�C�����w�� ---------------------------------------------------
open(15,file='z.data')      ! �C�\�ʂ̕ψ�
open(25,file='u.data')      ! ����
open(35,file='topo.data')   ! �n�ʂ܂��͊C��
!
! �X�b�e�v�w�� --------------------------------------------------------
nend=time_end/dt !���ԃX�e�b�v��
nout=time_out/dt !�o�̓f�[�^�X�e�b�v�Ԋu
index=0
!
! ���ԃ��[�v(n=0,nend�܂ŌJ��Ԃ�) ----------------------------------------
do n=0,nend
! �ŏ��̃X�e�b�v�̂݌��݃X�e�b�v�l���疢���X�e�b�v�l���v�Z�i�O������
if(n==0) then                                        !n=0�͏���̌v�Z�Ȃ̂ŁC�ߋ��̒l���Ȃ�
do i=1,iq
uf(i)=up(i)-grav*(dt/dx)*(zp(i+1)-zp(i))             !��U/��t=-g*��Z/��x
enddo
do i=2,iq
 depth0=(depth(i)+depth(i-1))*0.5
 depth1=(depth(i)+depth(i+1))*0.5
 zf(i)=zp(i)-(dt/dx)*(depth1*up(i)-depth0*up(i-1))   !��Z/��t=-��(HU)/��x
enddo
endif
! �ߋ��X�e�b�v�l�ƌ��݃X�e�b�v�l���疢���X�e�b�v�l���v�Z�i��������)
if(n>=1) then
do i=1,iq
uf(i)=ub(i)-2.*grav*(dt/dx)*(zp(i+1)-zp(i))           !��U/��t=-g*��Z/��x
enddo
do i=2,iq
 depth0=(depth(i)+depth(i-1))*0.5
 depth1=(depth(i)+depth(i+1))*0.5
 zf(i)=zb(i)-2.*(dt/dx)*(depth1*up(i)-depth0*up(i-1)) !��Z/��t=-��(HU)/��x
enddo
endif
! �����(depth<0)�ŗ�����0�ɂ��� ------------------
do i=1,iq
 if((depth(i)+depth(i+1))*0.5<=0.) uf(i)=0.
enddo
!
! �����̒Ôg�������I�Ɍ��������� ------------------
! i��iq-50�ȏ�̂Ƃ��͉��ɍs���قǔg���������Ȃ�悤��
 do i=1,iq
  if(i>=iq-50) zf(i)=zf(i)*(iq-i)/50.
  if(i>=iq-50) uf(i)=uf(i)*(iq-i)/50.
 enddo
! ���E���� -------
zf(1)=0.
zf(iq+1)=0.
!
! �v�Z�̈��艻�̂��߂̂��܂��Ȃ��iAsselin filter�j-------
if(n>=1) then
 eps=0.01
 do i=1,iq
  up(i)=up(i)+eps*(uf(i)-2.*up(i)+ub(i))
 enddo
 do i=1,iq+1
  zp(i)=zp(i)+eps*(zf(i)-2.*zp(i)+zb(i))
 enddo
 endif
!
! �f�[�^���t�@�C���o��(nout�X�e�b�v���Ƃ�) ------------------
if(mod(n,nout).eq.0) then
 do i=2,iq
  write(15,*) x(i)/1000., zp(i)
  write(25,*) x(i)/1000., up(i)  
  write(35,*) x(i)/1000., -depth(i)
 enddo
 write(15,*)
  write(15,*)
   write(25,*)
    write(25,*)
     write(35,*)
      write(35,*) 
       write(*,*) 'time(sec)=', dt*n, index
       index=index+1
       endif
!
!  �X�e�b�v��i�߂�
 do i=1,iq
  ub(i)=up(i)
 enddo
 do i=1,iq+1
  zb(i)=zp(i)
 enddo
 do i=1,iq
  up(i)=uf(i)
 enddo
 do i=1,iq+1
  zp(i)=zf(i)
 enddo
!
enddo
stop
end









