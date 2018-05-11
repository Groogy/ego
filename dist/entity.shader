#version 450

values
{
	worldTransform = world;
	viewTransform = camera;
	projectionTransform = projection;
}

depth
{
	enabled = true;
	function = LessEqual;
}

blend
{
  enabled = true;
  function = Add;
  sourceFactor = SourceAlpha;
  destinationFactor = OneMinusSourceAlpha;
}

vertex
{
	layout(location = 0) in vec4 position;
	layout(location = 1) in vec2 uv;
	layout(location = 2) in vec4 color;

	uniform mat4 world;
	uniform mat4 camera;
	uniform mat4 projection;

	out VertexData {
		vec4 position;
		vec2 uv;
		vec4 color;
		float zOrder;
	} outputVertex;

	void main()
	{
		vec4 pos = position;
		outputVertex.zOrder = pos.z;
		pos.z = 0;
		vec4 worldPos = world * pos;
		vec4 viewPos = camera * worldPos;
		gl_Position = projection * viewPos;
		outputVertex.position = worldPos;
		outputVertex.uv = uv;
		outputVertex.color = color;
	}
}

fragment
{
	layout(location = 0) out vec4 outputAlbedo;

	uniform sampler2D albedoSampler;

	uniform vec2 mapSize;

	in VertexData {
		vec4 position;
		vec2 uv;
		vec4 color;
		float zOrder;
	} inputVertex;

	void main()
	{
		vec2 texSize = textureSize(albedoSampler, 0);
		vec4 tex = texture(albedoSampler, inputVertex.uv / texSize);
		vec4 albedo = tex * inputVertex.color;
		if(albedo.a == 0)
			discard;

		outputAlbedo = albedo;
		gl_FragDepth = 1 - (inputVertex.zOrder + 1) / (mapSize.x * mapSize.y);
	}
}
