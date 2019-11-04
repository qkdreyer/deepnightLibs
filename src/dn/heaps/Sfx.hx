package dn.heaps;

#if !macro
import dn.M;
import hxd.snd.*;
import hxd.res.Sound;
#end


// --- GLOBAL PLAY GROUP ------------------------------------------------------
#if !macro
private class GlobalGroup {

	var id : Int;
	var volume : Float;
	public var group : SoundGroup;
	public var muted(default,set) : Bool;

	public function new(id:Int) {
		this.id = id;
		volume = 1;
		group = new hxd.snd.SoundGroup("global"+id);
	}

	public inline function setVolume(v) {
		volume = M.fclamp(v,0,1);
		group.volume = getVolume();
	}
	public inline function getVolume() {
		return muted ? 0 : volume;
	}

	function set_muted(v) {
		muted = v;
		if( v )
			group.volume = 0;
		else
			group.volume = volume;

		return v;
	}
}
#end


// --- SFX ------------------------------------------------------

class Sfx {
	macro public static function importDirectory(dir:String) {
		haxe.macro.Context.error("ERROR: importDirectory() is deprecated. Use dn.heaps.assets.SfxDirectory.load() instead.", haxe.macro.Context.currentPos());
		return macro null;
	}

	#if !macro
	static var GLOBAL_GROUPS : Map<Int, GlobalGroup> = new Map();
	public static var DEFAULT_GROUP_ID = 0;

	public var channel : Null<Channel>;
	public var sound : Sound;
	public var group(get,never) : Null<SoundGroup>;
	public var volume(default,set) : Float;
	public var groupId : Int;
	public var duration(get,never) : Float; inline function get_duration() return channel==null ? 0 : channel.duration;


	public function new(s:Sound) {
		sound = s;
		volume = 1;
		groupId = DEFAULT_GROUP_ID;
	}

	public function toString() {
		return Std.string(sound);
	}


	inline function get_group() return getGlobalGroup(groupId).group;

	inline function set_volume(v) {
		volume = M.fclamp(v,0,1);
		if( group!=null )
			group.volume = v;
		return volume;
	}



	static function getGlobalGroup(id) : GlobalGroup {
		if( !GLOBAL_GROUPS.exists(id) )
			GLOBAL_GROUPS.set(id, new GlobalGroup(id));
		return GLOBAL_GROUPS.get(id);
	}

	public static function setGroupVolume(id:Int, v:Float) {
		getGlobalGroup(id).setVolume(v);
	}

	public static function getGroupVolume(id:Int) {
		return getGlobalGroup(id).getVolume();
	}


	public inline function togglePlayStop(?loop=false, ?vol:Float) {
		if( isPlaying() ) {
			stop();
			return false;
		}
		else {
			play(loop, vol);
			return true;
		}
	}

	public function togglePlayPause() {
		if( !isPaused() ) {
			pause();
			return false;
		}
		else {
			resume();
			return true;
		}
	}

	public function pause() {
		if( channel!=null )
			channel.pause = true;
	}

	public function resume() {
		if( channel!=null )
			channel.pause = false;
	}

	public inline function isPaused() return channel!=null && channel.pause;

	public function play(?loop=false, ?vol:Float) {
		if( vol!=null )
			volume = vol;
		channel = sound.play(loop, volume, getGlobalGroup(groupId).group);
		channel.volume = volume*getGlobalGroup(groupId).getVolume();
		return this;
	}

	public inline function isPlaying() {
		return @:privateAccess sound.channel!=null && !isPaused();
	}
	public function stop() {
		sound.stop();
		channel = null;
	}


	public function playOnGroup(gid:Int, ?loop=false, ?vol:Float) {
		groupId = gid;
		play(loop, vol);
		return this;
	}


	public static function muteGroup(id) {
		getGlobalGroup(id).muted = true;
	}

	public static function unmuteGroup(id) {
		getGlobalGroup(id).muted = false;
	}

	public static function toggleMuteGroup(id) {
		var g = getGlobalGroup(id);
		g.muted = !g.muted;
		return g.muted;
	}

	public static inline function isMuted(id) {
		return getGlobalGroup(id).muted;
	}
	#end
}