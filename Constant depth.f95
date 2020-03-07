!���[�����ꍇ�̒Ôg�̉^���������ߎ����ŉ���
implicit none
!�ϐ��̌^�錾 --------------------------------------
integer, parameter :: iq=500
real*8 ::   uf(iq),  up(iq),  ub(iq)
real*8 ::   zf(iq+1),zp(iq+1),zb(iq+1)
real*8 ::   depth,width,grav,time_end,time_out,dx,dt,eps
integer ::  i,n,nend,nout,index
! �p�����[�^�̐ݒ� -------------------------
depth=100.           !���[ (m)
width=100.*1000.     !��(m)
grav=9.8             !�d�͉����x(m/s^2)
!------------------------------
time_end=2.*60.*60.  !�v�Z����(sec)
time_out=60.         !�f�[�^�o�͎��ԊԊu(sec)
!----------------------------
dx=width/iq      !��ԃO���b�h�T�C�Y
dt=1             !���ԃX�e�b�v�T�C�Y
do i=1,iq 
 up(i)=0.
end do
do i=1,iq+1
 zp(i)=exp(-dble(i-iq/2)**2/dble(iq/30)**2)
end do
!----�o�̓f�[�^�t�@�C�����w��--------
open(10,file='z.data')
open(20,file='u.data')
!------------------------------------
nend=time_end/dt  !���ԃX�e�b�v��
nout=time_out/dt  !�o�̓f�[�^�X�e�b�v�Ԋu
index=0
! ���ԃ��[�v(n=0,nend�܂ŌJ��Ԃ�) 
do n=0,nend
!**************************************************************
! �ŏ��̃X�e�b�v�̂݌��݃X�e�b�v�l���疢���X�e�b�v�l���v�Z�i�O�������j
    if(n==0) then
       do i=1,iq
         uf(i)=up(i)-grav*(dt/dx)*(zp(i+1)-zp(i))
       end do
       do i=2,iq
        zf(i)=zp(i)-depth*(dt/dx)*(up(i)-up(i-1))
       end do
    end if
! �ߋ��X�e�b�v�l�ƌ��݃X�e�b�v�l���疢���X�e�b�v�l���v�Z�i��������)
    if(n>=1) then
      do i=1,iq
        uf(i)=ub(i)-2*grav*(dt/dx)*(zp(i+1)-zp(i))
      end do
      do i=2,iq
        zf(i)=zb(i)-2*depth*(dt/dx)*(up(i)-up(i-1))
      end do
    end if
!---���E����----------
    uf(1 )=0.
    uf(iq)=0.
! �v�Z�̈��艻�̂��߂̂��܂��Ȃ��iAsselin filter�j-------
    if(n>=1) then
      eps=0.01
      do i=1,iq
        up(i)=up(i)+eps*(uf(i)-2*up(i)+ub(i))
      end do
      do i=1,iq+1
        zp(i)=zp(i)+eps*(zf(i)-2*zp(i)+zb(i))
      end do
    end if
 !---noutステップごとにデータをファイルに出力 --------------
    if(mod(n,nout).eq.0) then
       do i=2,iq
         write(10,*) dx*(i-2)/1000.,zp(i)
         write(20,*) dx*(i-2)/1000.,up(i)
       end do
       write(10,*)
       write(10,*)
       write(20,*)
       write(20,*)
       write(*,*) 'time (sec)=',dt*n,index
       index=index+1
    end if
! �f�[�^���t�@�C���o��(nout�X�e�b�v���Ƃ�) ------------------
    do i=1,iq
      ub(i)=up(i)
    end do
    do i=1,iq+1
      zb(i)=zp(i)
    end do
    do i=1,iq
      up(i)=uf(i)
    end do
    do i=1,iq+1
      zp(i)=zf(i)
    end do
!*****************************************************************
end do
stop
end
   

