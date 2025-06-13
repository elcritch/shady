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

proc roundedBoxShader(fragColor: var Vec4, uv: Vec2, time: Uniform[float32]) =
  # Center the UV coordinates
  let p = uv - vec2(0, 0)
  
  # Box size and corner radius
  let boxSize = vec2(200.0, 100.0)
  let radius = vec4(20.0, 20.0, 20.0, 20.0)  # All corners have same radius
  
  # Calculate distance
  let d = sdRoundedBox(p, boxSize, radius)
  
  # Color based on distance
  if d < 0.0:
    fragColor = vec4(1.0, 0.5, 0.2, 1.0)  # Orange inside
  else:
    # Fade out the edge
    let fade = 1.0 - min(d / 2.0, 1.0)
    fragColor = vec4(0.2, 0.2, 0.2, fade)  # Dark gray outside with fade

# Compile to a GPU shader:
var shader = toGLSL(roundedBoxShader)
echo shader

run("Rounded Box", shader) 