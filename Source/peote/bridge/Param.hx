package peote.bridge;

typedef Param = {
	onload:Void->Void,
	?onfail:Void->Void,
	?preferWebsockets:Bool,
	?proxys:Proxys
}