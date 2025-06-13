import chroma, shady, shady/demo, vmath

proc sdRoundedBox(p: Vec2, b: Vec2, r: Vec4): float32 =
  var r2 = r * 1.0
  r2.xy = if p.x > 0.0: r.xy else: r.zw
  r2.x = if p.y > 0.0: r2.x else: r2.y
  let q = abs(p) - b + r2.x
  return min(max(q.x, q.y), 0.0) + length(max(q, vec2(0.0))) - r2.x

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