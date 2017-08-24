#version 450

values
{
	worldTransform = world;
	viewTransform = ;
	projectionTransform = ;
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

	out VertexData {
		vec4 position;
		vec4 color;
		vec2 uv;
	} outputVertex;

	void main()
	{
		vec4 worldPos = position;
		gl_Position = worldPos;
		outputVertex.position = worldPos;
		outputVertex.color = color;
		outputVertex.uv = uv;
	}
}

fragment
{
	layout(location = 0) out vec4 outputAlbedo;

	in VertexData {
		vec4 position;
		vec4 color;
		vec2 uv;
	} inputVertex;

	void main()
	{
		outputAlbedo = inputVertex.color;
	}
}
