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
	layout(location = 0) in vec4 position;
	layout(location = 1) in vec4 color;

	uniform mat4 world;
	uniform mat4 camera;
	uniform mat4 projection;

	out VertexData {
		vec4 position;
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
		outputVertex.color = color;
	}
}

fragment
{
	layout(location = 0) out vec4 outputAlbedo;

	uniform vec2 mapSize;

	in VertexData {
		vec4 position;
		vec4 color;
		float zOrder;
	} inputVertex;

	void main()
	{
		outputAlbedo = inputVertex.color;
		gl_FragDepth = 1 - (inputVertex.zOrder + 1) / (mapSize.x * mapSize.y);
	}
}
