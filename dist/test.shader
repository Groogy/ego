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
	function = Always;
}

vertex
{
	layout(location = 0) in vec4 position;
	layout(location = 1) in vec4 color;
	layout(location = 2) in vec2 uv;

	uniform mat4 world;
	uniform mat4 camera;
	uniform mat4 projection;

	out VertexData {
		vec4 position;
		vec4 color;
		vec2 uv;
	} outputVertex;

	void main()
	{
		vec4 worldPos = position * world;
		vec4 viewPos = worldPos * camera;
		gl_Position = viewPos * projection;
		outputVertex.position = worldPos;
		outputVertex.color = color;
		outputVertex.uv = uv;
	}
}

fragment
{
	layout(location = 0) out vec4 outputAlbedo;

	uniform sampler2D albedoTexture;

	in VertexData {
		vec4 position;
		vec4 color;
		vec2 uv;
	} inputVertex;

	void main()
	{
		vec4 tex = texture(albedoTexture, inputVertex.uv);
		outputAlbedo = tex * inputVertex.color;
	}
}
