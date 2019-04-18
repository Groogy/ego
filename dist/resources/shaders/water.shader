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
	function = Less;
}

vertex
{
	layout(location = 0) in vec4 pos;
	layout(location = 1) in vec2 uv;

	uniform mat4 world;
	uniform mat4 camera;
	uniform mat4 projection;

	out VertexData {
		vec4 position;
		vec2 uv;
	} outputVertex;

	void main()
	{
		vec4 worldPos = world * pos;
		vec4 viewPos = camera * worldPos;
		gl_Position = projection * viewPos;
		outputVertex.position = worldPos;
		outputVertex.uv = uv;
	}
}

fragment
{
	layout(location = 0) out vec4 outputAlbedo;

	uniform sampler2D heatSampler;

	in VertexData {
		vec4 position;
		vec2 uv;
	} inputVertex;

	void main()
	{
		float heat = texture(heatSampler, inputVertex.uv).r;
		outputAlbedo = heat <= 0 ? vec4(1, 1, 1, 1) : vec4(0, 0, 1, 1);
	}
}
