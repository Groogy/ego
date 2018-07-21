#version 450

values
{
	worldTransform = world;
	viewTransform = camera;
	projectionTransform = projection;
}

depth
{
	enabled = false;
	function = Always;
}

vertex
{
	layout(location = 0) in vec4 position;
	layout(location = 1) in vec4 color;

	uniform mat4 world;
	uniform mat4 camera;
	uniform mat4 projection;

	uniform vec2 mapSize;

	out VertexData {
		vec4 position;
		vec4 color;
	} outputVertex;

	void main()
	{
		vec4 pos = position;
		vec4 worldPos = world * pos;
		vec4 viewPos = camera * worldPos;
		gl_Position = projection * viewPos;
		outputVertex.position = worldPos;
		outputVertex.color = color;
	}
}

fragment
{
	layout(location = 0) out vec4 outputAlbedo;

	in VertexData {
		vec4 position;
		vec4 color;
	} inputVertex;

	void main()
	{
		outputAlbedo = inputVertex.color;
	}
}
