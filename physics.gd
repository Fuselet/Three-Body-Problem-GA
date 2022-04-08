extends Node2D


var positions = [0,0,0,0,0,0]
var startpos = [0,0,0,0,0,0]
var oldpos: PoolVector2Array
var justreset = 100
var cameraoffset = Vector2(0,0)

#en pixel = detta värde i meter, 40000 pixlar = 1 AU
#scalesize = 1 --> 100 pixlar = 1 au
#var scalesize = 400
var scalesize = 1

var pixelscale = 1.495978707*pow(10,9)/scalesize

var G = 6.67408*pow(10,-11)*2.99*pow(10,30)/(pow(pixelscale,2))

#var mass = [1,0.000003,0] #för lagrangetesting
var mass = [1, 0.000003, 0.00095]
var sun
var planet
var moon
var textnodes
var buttonState

var moonplanetdiff
var lagrangechecking = false
var step = 0.5
var laststep = 1 #true = increase, false = decrease

# Called when the node enters the scene tree for the first time.
func _ready():
	sun = get_node("sun")
	planet = get_node("planet")
	moon = get_node("moon")
	#print(G)
	textnodes = [get_node("Camera2D/pos/sunx/sunxinput"), get_node("Camera2D/pos/suny/sunyinput"), get_node("Camera2D/vel/sunx/sunxinput"), get_node("Camera2D/vel/suny/sunyinput"), get_node("Camera2D/pos/planetx/planetxinput"), get_node("Camera2D/pos/planety/planetyinput"), get_node("Camera2D/vel/planetx/planetxinput"), get_node("Camera2D/vel/planety/planetyinput"), get_node("Camera2D/pos/moonx/moonxinput"), get_node("Camera2D/pos/moony/moonyinput"), get_node("Camera2D/vel/moonx/moonxinput"), get_node("Camera2D/vel/moony/moonyinput"), get_node("Camera2D/pos/difference")]
	#positions = [sun.global_position, Vector2(0, 0), Vector2(sun.global_position.x, sun.global_position.y + 100*scalesize), Vector2(pow(G*1/(100*scalesize), 0.5), 0), Vector2(0, 40401.06952), Vector2(0,0)]
	
#	positions[5] = lagrangespeed()

	#solen jorden jupiter
	#positions = [sun.global_position, Vector2(0, 0), Vector2(0, 100*scalesize), Vector2(pow(G*1/(100*scalesize), 0.5), 0), Vector2(0, 520.5*scalesize), Vector2(pow(G*1/(520.5*scalesize), 0.5), 0)]
	positions = [sun.global_position, Vector2(0, 0), planet.global_position, Vector2(1000, 0), moon.global_position, Vector2(0, -0.4)]
	for j in 6:
			textnodes[j*2].set_text(str(positions[j].x))
			textnodes[j*2 + 1].set_text(str(positions[j].y))
	moonplanetdiff = (positions[2] - positions[4]).length()
	startpos[0] = positions[4]
	startpos[1] = positions[5]

func lagrangespeed():
	var sunplanet = -positions[2]
	var sunmoon = -positions[4]
	var period = 2*PI*sunplanet.length()/positions[3].length()
	
	sunmoon.x = 0
	#var speed = pow(G*1/(sunplanet.length()), 0.5)
	
	var speed = 2*PI*sunmoon/period
	
	sunmoon = sunmoon.normalized() * speed
	
	
	var lagrangespeed = Vector2(sunmoon.y, -sunmoon.x)
	
	return lagrangespeed


func _draw():
	for i in 3:
		var length = oldpos.size()
		var line: PoolVector2Array
		for j in length/3:
			line.append(oldpos[i+3*j])
		draw_polyline(line, Color8(255, 255, 255))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var camera = get_node("Camera2D")
	var movedistance = 30
	camera.position = positions[0] + cameraoffset
	
	
	if Input.is_action_pressed("ui_left"):
		cameraoffset -= Vector2(movedistance,0)
	elif Input.is_action_pressed("ui_right"):
		cameraoffset += Vector2(movedistance,0)
	elif Input.is_action_pressed("ui_up"):
		cameraoffset -= Vector2(0,movedistance)
	elif Input.is_action_pressed("ui_down"):
		cameraoffset += Vector2(0,movedistance)
	
	
	if(buttonState == true):
		
		for i in 100:
			rungekutta(0.01, positions)
			
			var moonplanetdiffchange = moonplanetdiff - (positions[2] - positions[4]).length()
			moonplanetdiff = (positions[2] - positions[4]).length()
			#print(moonplanetdiffchange)
			if(lagrangechecking == true && justreset == 0):
				if(abs(moonplanetdiffchange) > 0.01):
					positions[0] = Vector2(0,0)
					positions[1] = Vector2(0,0)
					positions[2] = Vector2(0,40000)
					positions[3] = Vector2(pow(G*1/(100*scalesize), 0.5), 0)
					positions[4] = startpos[0]
					#positions = [Vector2(0,0), Vector2(0, 0), Vector2(0, 100*scalesize), Vector2(pow(G*1/(100*scalesize), 0.5), 0), Vector2(0, 100*scalesize + 3.346228*0.4*scalesize), Vector2(0,0)]
					if(moonplanetdiffchange > 0):
						if(laststep == 0):
							step = 0.9*step
						positions[4].y = positions[4].y + step
						positions[5] = lagrangespeed()
						laststep = 1
					else: 
						if(laststep == 1):
							step = 0.9*step
						positions[4].y = positions[4].y - step
						positions[5] = lagrangespeed()
						laststep = 0
					startpos[0] = positions[4]
					startpos[1] = positions[5]
					print(step)
					print(startpos)
					moonplanetdiff = (positions[2] - positions[4]).length()
					camera.position = positions[2] + Vector2(0, 0)
					justreset = 10
			else:
				justreset -= 1
		
		for j in 6:
			textnodes[j*2].set_text(str(positions[j].x))
			textnodes[j*2 + 1].set_text(str(positions[j].y))
		textnodes[12].set_text(str((positions[2]-positions[4]).length()))
		oldpos.append_array([sun.global_position, planet.global_position, moon.global_position])
	
		if oldpos.size() > 10000:
			for i in 3:
				oldpos.remove(0)
		update()
		
	else:
		for i in 6:
			positions[i] = Vector2(textnodes[i*2].text, textnodes[i*2 + 1].text)
	sun.position = positions[0]
	planet.position = positions[2]
	moon.position = positions[4]

func derivative():
	var dpositions = [Vector2(0,0), Vector2(0,0), Vector2(0,0), Vector2(0,0), Vector2(0,0), Vector2(0,0)]
	for i in 3:
		
		
		var start = i*2
		
		dpositions[start] = positions[start + 1] #velocity
		dpositions[start + 1] = acceleration(i) #acceleration
		
	return dpositions
		
		

#Numeriskt beräkna derivator
#h = tidssteg
#u = positioner
#func rungekutta(h, u):
#	var a = [0, h/2, h/2, h]
#	var b = [h/6, h/3, h/3, h/6]
#	var u0 = u
#	var ut = [Vector2(0,0),Vector2(0,0),Vector2(0,0),Vector2(0,0),Vector2(0,0),Vector2(0,0)]
#	var n = u.size()
#	var derivative = derivative()
#	for j in 4:
#		for i in n:
#			u0[i] = u0[i] + a[j]*derivative[i]
#			ut[i] = ut[i] + b[j]*derivative[i]
#	for i in n:
#		positions[i] = u0[i] + ut[i]
#

func rungekutta(h, u):
	var a = [0, h/2, h/2, h]
	var b = [h/6, h/3, h/3, h/6]
	var u0 = u
	var u1 = [Vector2(0,0), Vector2(0,0), Vector2(0,0), Vector2(0,0), Vector2(0,0), Vector2(0,0)]
	var n = u.size()
	
	
	var f0 = [Vector2(0,0), Vector2(0,0), Vector2(0,0), Vector2(0,0), Vector2(0,0), Vector2(0,0)]
	for i in n/2:
		f0[i*2] = positions[i*2+1]
		var otherbody = [i]
		for j in n/2:
			if i != j:
				otherbody.append(j)
		f0[i*2+1] = f(positions[otherbody[1]*2] - positions[i*2], positions[otherbody[2]*2] - positions[i*2], otherbody[0], otherbody[1], otherbody[2])
	
	
	var f1 = [Vector2(0,0), Vector2(0,0), Vector2(0,0), Vector2(0,0), Vector2(0,0), Vector2(0,0)]
	
	for i in n/2:
		f1[i*2] = positions[i*2+1] + h/2*f0[i*2]
		var otherbody = [i]
		for j in n/2:
			if i != j:
				otherbody.append(j)
		f1[i*2+1] = f(positions[otherbody[1]*2] - positions[i*2] + Vector2(h/2, h/2), positions[otherbody[2]*2] - positions[i*2] + Vector2(h/2*f0[otherbody[1]*2+1].x, h/2*f0[otherbody[1]*2+1].y), otherbody[0], otherbody[1], otherbody[2])
	
	var f2 = [Vector2(0,0), Vector2(0,0), Vector2(0,0), Vector2(0,0), Vector2(0,0), Vector2(0,0)]
	
	for i in n/2:
		f2[i*2] = positions[i*2+1] + h/2*f1[i*2]
		var otherbody = [i]
		for j in n/2:
			if i != j:
				otherbody.append(j)
		f2[i*2+1] = f(positions[otherbody[1]*2] - positions[i*2] + Vector2(h/2, h/2), positions[otherbody[2]*2] - positions[i*2] + Vector2(h/2*f1[otherbody[1]*2+1].x, h/2*f1[otherbody[1]*2+1].y), otherbody[0], otherbody[1], otherbody[2])
	
	var f3 = [Vector2(0,0), Vector2(0,0), Vector2(0,0), Vector2(0,0), Vector2(0,0), Vector2(0,0)]
	
	for i in n/2:
		f3[i*2] = positions[i*2+1] + h/2*f2[i*2]
		var otherbody = [i]
		for j in n/2:
			if i != j:
				otherbody.append(j)
		f3[i*2+1] = f(positions[otherbody[1]*2] - positions[i*2] + Vector2(h, h), positions[otherbody[2]*2] - positions[i*2] + Vector2(h*f2[otherbody[1]*2+1].x, h*f2[otherbody[1]*2+1].y), otherbody[0], otherbody[1], otherbody[2])
	
	for i in n:
		u1[i] = u0[i] + h*(f0[i] + 2*f1[i] + 2*f2[i] + f3[i])/6
	for i in n:
		positions[i] = u1[i]

func f(pos1, pos2, _bod1, bod2, bod3):
	var result = G*(mass[bod2]*(pos1)/(pow((pos1).length(),3)) + mass[bod3]*(pos2)/(pow((pos2).length(),3)))
	return G*(mass[bod2]*(pos1)/(pow((pos1).length(),3)) + mass[bod3]*(pos2)/(pow((pos2).length(),3)))


func to_meter(value):
	#1 pixel = 4.49548*10^12 m
	#return value
	return value*4.49548*pow(10,0)

func to_pixel(value):
	return value/pixelscale
	
func to_kg(value):
	#1 solar mass = 1.99 * 10^30 kg
	return value*1.99*pow(10,30)



func acceleration(body):
	var result = Vector2(0,0)
	var start = body*2
	
	for otherbody in 3:
		if body != otherbody:
			
			var otherbodystart = otherbody*2
			

			#var distance = (positions[otherbodystart] - positions[start]).length()
			result += G*mass[otherbody]*(positions[otherbodystart]-positions[start])/(pow((positions[otherbodystart] - positions[start]).length(),3))
	#result = to_pixel(result)
	return result

func _on_CheckButton_toggled(button_pressed):
	buttonState = button_pressed
