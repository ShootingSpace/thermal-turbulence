!�ٶ�ѹ������FTCS��ʽ
!���¸Ķ������һ��vir_meshλ���ϵ���cal_p����  2012.10.14

!��ǻ100cm��100cm
!------------------------------------------------------
!U-x�����ٶȷ���,V-y�����ٶ�
!P-ѹ��ֵ
!F-������
!Vor-����
program velocity_pressure
implicit none
real*8, allocatable::U(:,:),Ut(:,:),V(:,:),Vt(:,:),P(:,:),Pt(:,:),d(:,:),Sp(:,:),f(:,:),vor(:,:)
real*8 max,dt,dx,dy,at,bt,w,du,max_du,dv,max_dv,dp,max_dp,max_d,re
integer i,j,a,b,time,k,n
!--------------------------------------------��������,����������������߽������������
!V����㡪��(i+1/2,j)
!U����㡪��(i,j+1/2)
!P����㡪��(i+1/2,j+1/2)
!F,vor����㡪��(i,j)
a=64
b=64
w=0.9
re=1000.
re=1./re
dx=1./a;dy=1./b
dt=0.5*dx
at=1./dx/dx
bt=1./dy/dy
!dt=1./a/b
allocate( U(-a-2:a+2,-b-2:b+2),Ut(-a-2:a+2,-b-2:b+2),V(-a-2:a+2,-b-2:b+2),Vt(-a-2:a+2,-b-2:b+2) )
allocate( P(-a-2:a+2,-b-2:b+2),Pt(-a-2:a+2,-b-2:b+2),D(-a-2:a+2,-b-2:b+2),Sp(-a-2:a+2,-b-2:b+2) )
allocate( F(-a-2:a+2,-b-2:b+2),Vor(-a-2:a+2,-b-2:b+2) )
!*************************************************************
U=0.
V=0.
P=0.
U(:,b)=1.	!��ʼֵ
u(:,b+1)=2.*U(:,b)-u(:,b-1)
!----------------------------------�߽�����----------------
!AD&BC���:p(i+1,j)-p(i,j)=0
!			U=V=0,  U(i+1,j)=-U(i,j), V(i,j)=V(i,J+1)=0
!AB&CD���±ߣ�P(i,j+1)-P(i,j)=0
!			U+V=0,  U(i,j)=U(i+1,j)=0, V(i,j)=-V(i,j+1)
!����ѹ���ݶȽ���Ϊ0
!---------------------------------------
call vir_mesh(U,V,U,V)	!����������ֵ����
!==============================================================
time=0
do while( 1>0)

max=0.
 
call cal_UV  	!����U��V

call vir_mesh(Ut,Vt,Ut,Vt)
U=Ut;v=vt
 
call cal_D  	!����D

call cal_Sp		!����Sp
 
call cal_P		!����P

!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
if(mod(time,500)==0)then
	k=time/500
call position_UV  !��ڵ��ٶ�
call cal_stream !����������
call cal_vorticity !��������
call position_P  !����ѹ�����������ϵ�ֵ
call max_value

	open(10,file='data_'//char(48+mod(k/1000,10))//char(48+mod(k/100,10))//char&
	&(48+mod(k/10,10))//char(48+mod(k,10))//'.dat',status='unknown')
	write(10,"('TITLE=""grid=',I3,',Re=',f6.1,'"" ')")a,1./re
	write(10,*)'VARIABLES= "X" , "Y" ,"U","v","Ut","P","f","vor"'
	write(10,*)'ZONE I=',a+1,', J=',b+1,' F=POINT'

	do i=-a*0.5,a*0.5
	do j=-b*0.5,b*0.5
		write(10,*)i+0.5*a,j+0.5*b,U(2.*i,2.*j),v(2.*i,2.*j),ut(2.*i,2.*j),P(2.*i,2.*j),F(2.*i,2.*j),vor(2.*i,2.*j)
	enddo
	enddo
	close(10)

endif
!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


time=time+1

!-------------------------�ж��Ƿ�ﵽ����ʱ�̻�����̬����----
max=max_du
if(max<max_dv) max=max_dv


!if (time>3000)  then
if(mod(time,200)==0)then
write(*,*) time,max_du,max_dv,max_dp,max
end if
!else 
!print*,time,max_du,max_dv,max_dP
!endif
	
!if(max<max_dp) max=max_dp	 !ѹǿ�ƺ�����Ҫ�������жϿ��Ƿ�Χ������

if(max<1.E-005) exit	  




enddo

call position_UV  !��ڵ��ٶ�
call cal_stream !����������
call cal_vorticity !��������

call position_P  !����ѹ�����������ϵ�ֵ

!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	open(10,file='output_f.dat')
	write(10,*)'TITLE=""grid=',a,',re=',1./re,'""'
	write(10,*)'VARIABLES= "X" , "Y" ,"U","v","Ut","P","f","vor"'
	write(10,*)'ZONE I=',a+1,', J=',b+1,' F=POINT'

	do i=-a*0.5,a*0.5
	do j=-b*0.5,b*0.5
		write(10,*)i+0.5*a,j+0.5*b,U(2.*i,2.*j),v(2.*i,2.*j),ut(2.*i,2.*j),P(2.*i,2.*j),F(2.*i,2.*j),vor(2.*i,2.*j)
	enddo
	enddo
	close(10)
!++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

deallocate(Ut,U,V,Vt,P,Pt)
10 format(1x,f10.5)
contains
!*************************************************************
subroutine vir_mesh(U,V,U0,V0)
real*8  U(-a-2:a+2,-b-2:b+2),U0(-a-2:a+2,-b-2:b+2),V(-a-2:a+2,-b-2:b+2),V0(-a-2:a+2,-b-2:b+2)

	!AD 
	U0(-a-2,:)=-1*u(-a+2,:)
	V0(-a-1,:)=-1*v(-a+1,:)
	!BC  
	v0(a+1,:)=-v(a-1,:)
	U0(a+2,:)=-U(a-2,:)
	!CD  
	U0(:,-b-1)=-U(:,-b+1)
	v0(:,-b-2)=-v(:,-b+2)
	!AB 
	v0(:,b+2)=-v(:,b-2)
	U0(:,b+1)=2.*U(:,b)-U(:,b-1)

end subroutine vir_mesh
!***************************************************************
subroutine cal_UV 

max_du=0;max_dv=0.

do i=-a+1,a-1,2
do j=-b+1,b-1,2

	Ut(i+1,j)= U(i+1,j)-0.25*dt/dx*( U(i+3,j)*(U(i+3,j)+2.*U(i+1,j)) -U(i-1,j)*(U(i-1,j)+2.*U(i+1,j)) )&
	&-0.25*dt/dy*( (U(i+1,j)+U(i+1,j+2))*(v(i,j+1)+v(i+2,j+1)) -(U(i+1,j-2)+U(i+1,j))*(v(i,j-1)+v(i+2,j-1)) )&
	&-dt/dx*(P(i+2,j)-P(i,j))&
	&+dt*at*( U(i+3,j)-2.*U(i+1,j)+U(i-1,j) )*re +dt*bt*( U(i+1,j+2)-2.*U(i+1,j)+U(i+1,j-2) )*re
	
	vt(i,j+1)= v(i,j+1)-0.25*dt/dy*( v(i,j+3)*(v(i,j+3)+2.*v(i,j+1)) -v(i,j-1)*(v(i,j-1)+2.*v(i,j+1)) )&
	&-0.25*dt/dx*( (U(i+1,j+2)+U(i+1,j))*(v(i+2,j+1)+v(i,j+1)) -(u(i-1,j+2)+u(i-1,j))*(v(i,j+1)+v(i-2,j+1)) )&
	&-dt/dy*(P(i,j+2)-P(i,j))&
	&+dt*at*( v(i+2,j+1)-2.*v(i,j+1)+v(i-2,j+1) )*re +dt*bt*( v(i,j+3)-2.*v(i,j+1)+v(i,j-1) )*re
	
	if(i/=a-1) then
		du=abs(Ut(i+1,j)-U(i+1,j))
	endif
	if(j/=b-1) then
		dv=abs(vt(i,j+1)-v(i,j+1))
	endif
	if(max_du<du) max_du=du
	if(max_dv<dv) max_dv=dv
enddo
enddo
Ut(:,b)=1.; Ut(:,-b)=0.; Ut(-a,:)=0.; Ut(a,:)=0.
vt(:,b)=0.; vt(:,-b)=0.; vt(-a,:)=0.; vt(a,:)=0.

end subroutine cal_UV

!**************************************************************

subroutine cal_D 

do i=-a+1,a-1,2
do j=-b+1,b-1,2
	d(i,j)=(ut(i+1,j)-ut(i-1,j))/dx +(vt(i,j+1)-vt(i,j-1))/dy

enddo
enddo	

end subroutine cal_D

!**************************************************************************
subroutine cal_Sp

do i=-a+1,a-1,2
do j=-b+1,b-1,2
	Sp(i,j)=D(i,j)/dt-0.25*at*( Ut(i+3,j)*Ut(i+3,j)-ut(i+1,j)*ut(i+1,j)-ut(i-1,j)*ut(i-1,j)+ut(i-3,j)*ut(i-3,j)&
	&+2.*Ut(i+1,j)*(Ut(i+3,j)-Ut(i-1,j))+2.*Ut(i-1,j)*(Ut(i-3,j)-Ut(i+1,j)) )&
	&-0.5/dx/dy*( (Ut(i+1,j+2)+Ut(i+1,j))*(Vt(i+2,j+1)+Vt(i,j+1)) -(Ut(i+1,j-2)+Ut(i+1,j))*(Vt(i+2,j-1)+Vt(i,j-1))&
	&-(Ut(i-1,j+2)+Ut(i-1,j))*(Vt(i,j+1)+Vt(i-2,j+1)) +(Ut(i-1,j)+Ut(i-1,j-2))*(Vt(i,j-1)+Vt(i-2,j-1)) )&
	&-0.25*bt*( Vt(i,j+3)**2-Vt(i,j+1)**2-Vt(i,j-1)**2+Vt(i,j-3)**2&
	&+2.*Vt(i,j+1)*(Vt(i,j+3)-Vt(i,j-1)) +2.*Vt(i,j-1)*(Vt(i,j-3)-Vt(i,j+1)) )&
	&+at*(D(i+2,j)-2.*D(i,j)+D(i-2,j))*re +bt*(D(i,j+2)-2.*D(i,j)+D(i,j-2))*re    		
enddo
enddo

end subroutine cal_Sp

!******************************************************************************
subroutine cal_P

do n=1,100

!do while(1>0)
max_dP=0.
do i=-a+1,a-1,2
do j=-b+1,b-1,2
	Pt(i,j)=0.5*( at*(P(i+2,j)+P(i-2,j))+bt*(P(i,j+2)+P(i,j-2))-Sp(i,j) )/(at+bt)
	Pt(i,j)=w*Pt(i,j)+(1-w)*P(i,j)
	dp=abs(Pt(i,j)-P(i,j)) 
	if(max_dp<dp) max_dp=dp
	P(i,j)=Pt(i,j)
enddo
enddo    
P(-a-1,:)=P(-a+1,:)
P(a+1,:)=P(a-1,:)
P(:,-b-1)=P(:,-b+1)
P(:,b+1)=P(:,b-1)

!print*, 'max',n,max_dp

if(max_dp<1.E-006) exit
enddo
!pause


end subroutine cal_P
!**********************************************************************************
subroutine cal_stream
real fu(-a-2:a+2,-b-2:b+2),fv(-a-2:a+2,-b-2:b+2)
fu= 0.          
fv= 0.
f(-a,:)=0.;f(a,:)=0.;f(:,-b)=0.;f(:,b)=0.
do i=-a+2,a-2,2
do j=-b+2,b-2,2
	fu(i,j)= dy*u(i,j-1)+fu(i,j-2)
end do
end do    
       
do j=-a+2,a-2,2
do i=-b+2,b-2,2
	fv(i,j)= -1.0*dx*v(i-1,j)+fv(i-2,j)
end do
end do    
       
do i=-a+2,a-2,2
do j=-b+2,b-2,2
	!f(0.5*i,0.5*j)= 0.5*(fu(i,j)+fv(i,j))
	 f(i,j)= 0.5*(fu(i,j)+fv(i,j))
end do
end do    

end subroutine cal_stream 
!**********************************************************************************
subroutine max_value
real*8 i_max,j_max,d
   do i=-a+2,a-2,2                                !���������ֵ
     do j=-b+2,b-2,2
       if (d<=f(i,j)) then 
           d=f(i,j)
           i_max=i
           j_max=j
       end if
          
    end do
  end do
    write(11,*)"flow_functioin_max:"
    write(11,"(f15.10,I5,I5,f15.10,f15.10)")d,i_max,j_max,real(i_max)*dx,real(j_max)*dy
    
    d=0.0                         !�ϱ����к������ֵ
    do i=-a+2,a-2,2
        if (d<=vor(i,b)) then 
           d=vor(i,b)
           i_max=i
       end if
          
    end do
           write(11,*)"up_wall_vortex_functioin_max:"
           write(11,"(f15.10,I5,f15.10)")d,i_max,real(i_max)*dx
    
       d=0.0                      !���������к������ֵ
    do j=-b+2,b-2,2
        if (d<=vor(0,j)) then 
           d=vor(0,j)
           j_max=j
       end if
           
    end do
         write(11,*)"middle_line_vortex_functioin_max:"
         write(11,"(f15.10,I5,f15.10)")d,j_max,real(j_max)*dy
         


end subroutine max_value
!*****************************************************************
subroutine cal_vorticity

do i=-a+2,a-2,2        !����������
do j=-b+2,b-2,2   
	!vor(0.5*i,0.5*j)= (v(i+1,j)-v(i-1,j))/dx - (u(i,j+1)-u(i,j-1))/dy
	vor(i,j)= (v(i+1,j)-v(i-1,j))/dx - (u(i,j+1)-u(i,j-1))/dy
end do
end do    
    
                       !��߽��ϵ���������
     do j=-b+2,b-2,2
       vor(-a,j)= (v(-a+1,j)-v(-a-1,j))/dx   !left wall
     end do
     
     do j=-b+2,b-2,2
       vor(a,j)= (v(a+1,j)-v(a-1,j))/dx    !right wall
     end do
     
     do i=-a+2,a-2,2
       vor(i,b)= (u(i,b+1)-u(i,b-1))/dy    !up wall
     end do
     
     do i=-a+2,a-2,2
       vor(i,-b)= (u(i,-b+1)-u(i,-b-1))/dy    !down wall
     end do
     
                     !����ǵ���������
                     
      vor(-a,-b)= 0.5*(vor(-a,-b+1) +  vor(-a+1,-b))
      vor(-a,b)= 0.5*(vor(-a,b-1) +  vor(-a+1,b))
      vor(a,-b)= 0.5*(vor(a-1,-b) +  vor(a,-b+1))
      vor(a,b)= 0.5*(vor(a,b-1) +  vor(a-1,b))
      
end subroutine cal_vorticity

!************************************************************
subroutine position_UV

do j=-a+2,a-2,2          !����u �ٶ�������ڵ��ϵ�ֵ
do i=-b+2,b-2,2
U(i,j)=(u(i,j+1)+u(i,j-1))*0.5  
end do
end do
 
do i=-a+2,a-2,2         !����v �ٶ�������ڵ��ϵ�ֵ
do j=-b+2,b-2,2
v(i,j)=(v(i+1,j)+v(i-1,j))*0.5
end do
end do   
UT=0. 
do j=-a+2,a-2,2           !��ڵ��ٶȾ���ֵ
do i=-b+2,b-2,2
ut(i,j)= sqrt(u(i,j)*u(i,j) + v(i,j)*v(i,j))
end do
end do   

end subroutine position_UV

!*************************************************************
subroutine position_P
							!����ѹ�����������ϵ�ֵ
do i=-a,a,2
do j=-a,b,2
P(i,j)=0.25*(p(i+1,j+1)+p(i-1,j+1)+p(i-1,j-1)+p(i+1,j-1))
enddo	
enddo

end subroutine position_P

!*************************************************************
end
