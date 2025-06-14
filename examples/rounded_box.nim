import chroma, shady, shady/demo, vmath

func sdRoundedBox*(p: Vec2, b: Vec2, r: Vec4): float32 =
  ## Signed distance function for a rounded box
  ## p: point to test
  ## b: box half-extents (width/2, height/2)
  ## r: corner radii as Vec4 (x=top-right, y=bottom-right, z=bottom-left, w=top-left)
  ## Returns: signed distance (negative inside, positive outside)
  var cornerRadius = r
  
  # Select appropriate corner radius based on quadrant
  cornerRadius.xy = if p.x > 0.0: r.xy else: r.zw
  cornerRadius.x = if p.y > 0.0: cornerRadius.x else: cornerRadius.y
  
  # Calculate distance
  let q = abs(p) - b + vec2(cornerRadius.x, cornerRadius.x)
  
  result = min(max(q.x, q.y), 0.0) + length(max(q, vec2(0.0, 0.0))) - cornerRadius.x
 
proc gaussian(x: float32, s: float32): float32 =
  result = 1.0 / (s * sqrt(2.0 * PI)) * exp(-1.0 * pow(x, 2) / (2.0 * pow(s, 2)))

proc dropShadow(sd: float32, stdDevFactor: float32, spread: float32, factor: float32): float32 = 
  let s = stdDevFactor
  let sdP = sd - spread + 1
  let x = sdP / (factor + 0.5)
  let f = gaussian(x, s)
  # return pow(f, 1.0/2.2)
  return f

proc roundedBoxShader(fragColor: var Vec4, uv: Vec2, posColor: Uniform[Vec4], negColor: Uniform[Vec4], time: Uniform[float32]) =
  # Center the UV coordinates
  let p = uv - vec2(0, 0)
  
  # fragColor = posColor
  # Box size and corner radius
  let boxSize = vec2(50.0, 50.0)
  let radius = vec4(20.0, 20.0, 20.0, 20.0)  # All corners have same radius
  
  # Calculate distance
  let sd = sdRoundedBox(p, boxSize, radius)
  
  # Color based on distance
  if sd < 0.0:
    fragColor = posColor
    let f = min(1.0, dropShadow(1 - sd, stdDevFactor=1.0/2.2, spread=10.0, factor=10.0))
    fragColor = mix(posColor, negColor, f)
  else:
    fragColor = negColor
    let f = min(1.0, dropShadow(sd, stdDevFactor=1.0/2.2, spread=10.0, factor=10.0))
    fragColor = mix(posColor, negColor, f)
    discard

# Compile to a GPU shader:
var shader = toGLSL(roundedBoxShader)
echo shader

let pos = vec4(1.0, 0.5, 0.2, 0.5)
let neg = vec4(0.0, 0.0, 0.0, 0.5)
run("Rounded Box", shader, pos, neg)
