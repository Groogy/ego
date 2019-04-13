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

	uniform mat4 world;
	uniform mat4 camera;
	uniform mat4 projection;

	out VertexData {
		vec4 position;
	} outputVertex;

	void main()
	{
		vec4 worldPos = world * pos;
		vec4 viewPos = camera * worldPos;
		gl_Position = projection * viewPos;
		outputVertex.position = worldPos;
	}
}

fragment
{
	layout(location = 0) out vec4 outputAlbedo;

	in VertexData {
		vec4 position;
	} inputVertex;

	void main()
	{
		outputAlbedo = vec4(0, 0, 1, 1);
	}
}
