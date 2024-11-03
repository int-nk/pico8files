pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--main

--bugs
		

function _init()
	cls()
	ballr=3

	balls={}
	makeballs()
	tmax=0
	t=0
	friction=0.99
	stick={
	x=64,
	y=64,
	ang=0,
	dist=5,
	}

	state="serve"
	ballx=balls[1].x
	bally=balls[1].y
	debug1=true
	debug2=0
	debug3=0
	
	hole={}
	for i=0,5 do
		if i > 2 then
			ty=128-16
		else
			ty=16
		end
		add(hole,{
		x=60*(i%3)+4, 
		y=ty, 
		r=ballr+1,
		dx=0,
		dy=0
		})
	end
	
	dot={}
	for i=1,60 do
		add(dot, {
		x=balls[1].x,
		y=balls[1].y
		})
	end
end

function _update60()
	t+=1
--if btn(❎) then
	serveball()
--end
	
	
	
	

end

function _draw()
	cls()
	
	--rectfill(6
	rectfill(0,12,128,128-12,3)
	rectfill(9,12,64-5,20,4)
	rectfill(64+5,12,119,20,4)
	--rectfill(0,12,128,128-20,3)
	rectfill(9,128-12,64-5,128-20,4)
	rectfill(64+5,128-12,119,128-20,4)
	
	--rectfill(0,20,128,128-20,3)
	--rectfill(0,20,128,25,1)
	
	--shadows
	for ball in all(balls) do
		circfill(ball.x,ball.y+ball.r,
		ball.r,1)
	end
--	circfill(cue.x,cue.y+cue.r,
--	cue.r,1)
	
	for i=1, #hole-3 do
		circfill(hole[i].x,hole[i].y,
		hole[i].r,0)
	end
--	for h in all(hole) do
--		
--	end
	
	
	--circfill(cue.x,cue.y,cue.r,7)
	
	for ball in all(balls) do
		if (ball.inhole) ball.r-=0.4
		circfill(ball.x,ball.y,
		ball.r,ball.c)
		print("["..flr(ball.x)..", "..
		flr(ball.y).."]")
	
	end
--	print("["..debug2..", "..debug3)
--	print(balls[1].dx.. " "..balls[1].dy)
	--rectfill(0,128-20,128,128-12,4)
	--circfill(4,15,4,0)
	
	for i=4, #hole do
		circfill(hole[i].x,hole[i].y,
		hole[i].r,0)
	end

	--print(debug1,0,0,7)
	if state=="serve" then
		line(stick.x,stick.y,
		balls[1].x,balls[1].y,8)
		print("🅾️:serve",0,120,7)
		print("⬅️➡️:aim",40,120,7)
	end
	
end

function serveball()
	if foul then
		if t > tmax then
			add(balls,{
			x=32,
			y=64,
			dx=0,
			nextx=0,
			nexty=0,
			r=ballr,
			dy=0,
			c=7
			},1)
			foul=false
			state="move"
		end
	end
	
	if state=="move" then
		moveball()
	elseif state=="serve" then
		if btn(➡️) then
			stick.ang+=0.005
		end
		if btn(⬅️) then
			stick.ang-=0.005
		end
		if btn(⬆️) then
			stick.dist+=0.5
		end
		if btn(⬇️) then
			stick.dist-=0.5
		end
			stick.dist=mid(2,stick.dist,30)
			stick.x=stick.dist*sin(stick.ang)+balls[1].x
			stick.y=stick.dist*cos(stick.ang)+balls[1].y
		if btnp(🅾️) then
			balls[1].dx=sin(stick.ang)*(stick.dist/5)
			balls[1].dy=cos(stick.ang)*(stick.dist/5)
			sfx(2)
			state="hit"
		end
		hitball()
	elseif state=="hit" then
		hitball()
	end
end

function hitball()

--	if state=="hit" then
--		cue.dx*=friction
--		cue.dy*=friction
--		
--		cue.x+=cue.dx
--		cue.y+=cue.dy
--	end
		
	
	for ball in all(balls) do

			ball.dx*=friction
			ball.dy*=friction
			
			ball.x+=ball.dx
			ball.y+=ball.dy
		--	debug1=ball.dy
			ballx=ball.x
			bally=ball.y
			if #balls > 1 then
				for b in all(balls) do
					if ball.c != b.c and
					collision(ball,b) then
						collisionwork(ball,b)
						b.hit=true
						ball.hit=true
					end
				end
			end
			
--			for h in all(hole) do
--				if inhole(ball,h) then
--					ball.inhole=true
--					ball.dx/=4
--					ball.dy/=4
--					if ball.c==balls[1].c then
--						--cue ball, foul
--						foul=true
--					end
--				end
--
--			end
			
			if ball.x<ball.r or ball.x>128-ball.r then
				ball.x=mid(ball.x,ball.r,128-ball.r)
				ball.dx=-ball.dx
				sfx(1)
			end
			if ball.y<20+ball.r or ball.y>128-20-ball.r then
				ball.y=mid(ball.y,20+ball.r,128-20-ball.r)
				ball.dy=-ball.dy
				sfx(1)
			end
			
		if ball.r<0 then
			del(balls,ball)
		end
	
	end


	

	slow = true
	for i=1, #balls do
		 
		if abs(balls[i].dx)>=0.001
		and abs(balls[i].dy)>=0.001 then
			slow = false
		else
--			balls[i].dx=0
--			balls[i].dy=0
		end
	end
	if slow then
		if (foul) tmax=t+60
		state="serve"
	end
end

function collision(a,b)
	return (b.x-a.x)^2+(b.y-a.y)^2 <= (a.r+b.r+1)^2
end

function inhole(a,b)
	--debug1 = (b.x-a.x)^2+(b.y-a.y)^2 >= (a.r+b.r)^2
	return (b.x-a.x-4)^2+(b.y-a.y-4)^2 <= (a.r+b.r)^2
end


function getsign(n)
	if n < 0 then return -1
	else return 1 end
end

function movexy(a,b)

while collision(a,b) do
	b.x+=b.dx
	b.y+=b.dy
end

--	b.x+=getsign(b.dx)*(b.x%b.r+0.25)
--	b.y+=getsign(b.dy)*(b.y%b.r+0.25)
	return b.x,b.y
end
-->8
function collisionwork(a,b)


	debug2=sin(atan2(b.y-a.y,b.x-a.x))*abs(a.dx)
	debug3=cos(atan2(b.y-a.y,b.x-a.x))*abs(a.dy)
	b.dx=debug2
	b.dy=debug3
	
	a.dy-=b.dy
	a.dx-=b.dx
--
	--b.x,b.y=movexy(a,b)
		
--		dot[1].x=b.x
--		dot[1].y=b.y
--		for i=2,#dot do
--			if dot[i] then
--				dot[i].x=dot[i-1].x+b.dx
--				dot[i].y=dot[i-1].y+b.dy
--				
--			end
--		end
		
			sfx(0)
end
-->8
function makeballs()
	add(balls,{
	--cue ball
	x=32,
	y=64,
	dx=0,
	nextx=0,
	nexty=0,
	r=ballr,
	dy=0,
	c=7,
	hit=false
	})
	
	add(balls,{
	x=64,
	y=64,
	dx=0,
	r=ballr,
	inhole=false,
	dy=0,
	c=10,
	hit=false
	})
	
--	add(balls,{
--	x=72,
--	y=60,
--	dx=0,
--	r=ballr,
--	nextx=0,
--	nexty=0,
--	dy=0,
--	c=12
--	})
--	add(balls,{
--	x=72,
--	y=69,
--	dx=0,
--	r=ballr,
--	nextx=0,
--	nexty=0,
--	dy=0,
--	c=8
--	})
--	
--	add(balls,{
--	x=80,
--	y=58,
--	dx=0,
--	r=ballr,
--	nextx=0,
--	nexty=0,
--	dy=0,
--	c=9
--	})
--	add(balls,{
--	x=80,
--	y=68,
--	dx=0,
--	r=ballr,
--	nextx=0,
--	nexty=0,
--	dy=0,
--	c=15
--	})
end

function moveball()
	if (btn(⬅️)) balls[1].x-=1
	if (btn(➡️)) balls[1].x+=1
	if (btn(⬆️)) balls[1].y-=1
	if (btn(⬇️)) balls[1].y+=1
	if btn(🅾️) then 
		state="serve"
	end
	
	
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
77007770777000000000770077707770077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70007070007000000000070070707000007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70007770007000000000070070707770007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
70000070007007000000070070700070007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77000070007070000000777077707770077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aa00aaa0aaa000000000a0a0aaa00aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a000a0a0a0a000000000a0a0a0a000a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a000aaa0aaa000000000aaa0aaa000a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a000a0a000a00a00000000a0a0a000a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
aa00aaa000a0a000000000a0aaa00aa0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33300033344444444444444444444444444444444444444444444444444433300033344444444444444444444444444444444444444444444444444433300033
30000000344444444444444444444444444444444444444444444444444430000000344444444444444444444444444444444444444444444444444430000000
30000000344444444444444444444444444444444444444444444444444430000000344444444444444444444444444444444444444444444444444430000000
00000000044444444444444444444444444444444444444444444444444400000000044444444444444444444444444444444444444444444444444400000000
00000000044444444444444444444444444444444444444444444444444400000000044444444444444444444444444444444444444444444444444400000000
00000000044444444444444444444444444444444444444444444444444400000000044444444444444444444444444444444444444444444444444400000000
30000000344444444444444444444444444444444444444444444444444430000000344444444444444444444444444444444444444444444444444430000000
30000000344444444444444444444444444444444444444444444444444430000000344444444444444444444444444444444444444444444444444430000000
33300033344444444444444444444444444444444444444444444444444433300033344444444444444444444444444444444444444444444444444433300033
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
3333333333333333333333333333333333333333333333333333333333333333333333333333333333333333aaa3333333333333333333333333333333333333
333333333333333333333333333333333333333333333333333333333333333333333333333333333333333aaaaa333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333aaaaaaa33333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333aaaaaaa33333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333aaaaaaa33333333333333333333333333333333333
333333333333333333333333333333333333333333333333333333333333333333333333333333333333331aaaaa133333333333333333333333333333333333
3333333333333333333333333333333333333333333333333333333333333333333333333333333333333311aaa1133333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333111111133333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333311111333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333331113333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333377733333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333777773333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333337777777333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333337777777333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333337777777333333333333333333333333333
33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333331777771333333333333333333333333333
33300033344444444444444444444444444444444444444444444444444433300033344444444444444444444444441177711444444444444444444433300033
30000000344444444444444444444444444444444444444444444444444430000000344444444444444444444444441111111444444444444444444430000000
30000000344444444444444444444444444444444444444444444444444430000000344444444444444444444444444111114444444444444444444430000000
00000000044444444444444444444444444444444444444444444444444400000000044444444444444444444444444411144444444444444444444400000000
00000000044444444444444444444444444444444444444444444444444400000000044444444444444444444444444444444444444444444444444400000000
00000000044444444444444444444444444444444444444444444444444400000000044444444444444444444444444444444444444444444444444400000000
30000000344444444444444444444444444444444444444444444444444430000000344444444444444444444444444444444444444444444444444430000000
30000000344444444444444444444444444444444444444444444444444430000000344444444444444444444444444444444444444444444444444430000000
33300033344444444444444444444444444444444444444444444444444433300033344444444444444444444444444444444444444444444444444433300033
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__sfx__
020100003d64636666316763066628656256461e636186160f6162260600606006060060600606006060060600606006060060600606006060060600606006060060600606006060060600606006060060600606
95010000256552665526655226551b655146550a65505655006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605006050060500605
00010000386503565034650316502f6402d6402a630276202562023610206101c6101761015610106100a60007600036000060003600026000060000600016000000000000000000000000000000000000000000
