class PerlinNoise
  include CrystalClear

  REFERENCE = {
    151,160,137,91,90,15,131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,
		8,99,37,240,21,10,23,190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,
		35,11,32,57,177,33,88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,
		134,139,48,27,166,77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,
		55,46,245,40,244,102,143,54, 65,25,63,161,1,216,80,73,209,76,132,187,208, 89,
		18,169,200,196,135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,
		250,124,123,5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,
		189,28,42,223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 
		43,172,9,129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,
		97,228,251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,
		107,49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
		138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
  }

  @permutation = [] of UInt8

  def initialize()
    2.times do
      REFERENCE.each do |val|
        @permutation << val.to_u8
      end
    end
  end

  def initialize(seed)
    random = Boleite::NoiseRandom.new seed
    256.times do |i|
      @permutation << i.to_u8
    end
    @permutation.shuffle! random
    @permutation.concat @permutation.dup
  end

  def noise(x : Float64, y : Float64, z : Float64) : Float64
    xi = x.to_i & 255
    yi = y.to_i & 255
    zi = z.to_i & 255
    xf = x - x.floor
    yf = y - y.floor
    zf = z - z.floor
    u = fade xf
    v = fade yf
    w = fade zf

    aaa = p[p[p[    xi ]+    yi ]+    zi ]
    aba = p[p[p[    xi ]+   yi+1]+    zi ]
    aab = p[p[p[    xi ]+    yi ]+   zi+1]
    abb = p[p[p[    xi ]+   yi+1]+   zi+1]
    baa = p[p[p[   xi+1]+    yi ]+    zi ]
    bba = p[p[p[   xi+1]+   yi+1]+    zi ]
    bab = p[p[p[   xi+1]+    yi ]+   zi+1]
    bbb = p[p[p[   xi+1]+   yi+1]+   zi+1]

    x1 = lerp(grad(aaa, xf , yf, zf), grad(baa, xf-1, yf, zf), u)
    x2 = lerp(grad(aba, xf, yf-1, zf), grad(bba, xf-1, yf-1, zf), u)
    y1 = lerp(x1, x2, v)

    x1 = lerp(grad(aab, xf, yf, zf-1), grad(bab, xf-1, yf, zf-1), u)
    x2 = lerp(grad(abb, xf, yf-1, zf-1), grad(bbb, xf-1, yf-1, zf-1), u)
    y2 = lerp(x1, x2, v)

    return (lerp(y1, y2, w)+1.0)/2.0
  end

  private def fade(t : Float64) : Float64
    t * t * t * (t * (t * 6.0 - 15.0) + 10.0)
  end

  private def lerp(a : Float64, b : Float64, t : Float64) : Float64
    a + t * (b - a)
  end

  private def grad(hash, x : Float64, y : Float64, z : Float64) : Float64
    case hash & 0xF
    when 0x0 then x + y;
    when 0x1 then -x + y;
    when 0x2 then  x - y;
    when 0x3 then -x - y;
    when 0x4 then  x + z;
    when 0x5 then -x + z;
    when 0x6 then  x - z;
    when 0x7 then -x - z;
    when 0x8 then  y + z;
    when 0x9 then -y + z;
    when 0xA then  y - z;
    when 0xB then -y - z;
    when 0xC then  y + x;
    when 0xD then -y + z;
    when 0xE then  y - x;
    when 0xF then -y - z;
    else raise "Should never happen"
    end
  end

  private def p
    @permutation
  end

  invariant @permutation.size == 512
end