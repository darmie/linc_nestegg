package nestegg;

import haxe.io.UInt8Array;
import sys.io.FileInput;
import sys.io.File;
import cpp.FILE;
import cpp.UInt8;
import cpp.Int32;
import cpp.Int64;
import cpp.UInt32;
import cpp.SizeT;
import cpp.Pointer;
import cpp.ConstPointer;
import cpp.Float64;
import cpp.UInt64;
import cpp.Callable;
import haxe.io.BytesData;

@:keep
@:structAccess
@:include('linc_nestegg.h')
#if !display
@:build(linc.Linc.touch())
@:build(linc.Linc.xml('nestegg'))
#end
@:native("linc::nestegg::nestegg")
extern class Nestegg {
	@:native("linc::nestegg::sniff")
	public static function sniff(buffer:cpp.ConstPointer<BytesData>, length:Int):Bool;

   
	public static inline function init(path:String, max_offset:cpp.Int64):Pointer<Nestegg> {
        return untyped  __cpp__("new linc::nestegg::nestegg({0},{1})", path, max_offset);
    }

	@:native("duration") 
	public function duration(duration:cpp.Pointer<UInt64>):Bool;

	@:native("tstamp_scale")
	public function tstamp_scale(scale:cpp.Pointer<UInt64>):Bool;

	@:native("track_count")
	public function track_count(tracks:cpp.Pointer<UInt32>):Bool;

	@:native("get_cue_point")
	public function get_cue_point(cluster_num:cpp.UInt32, max_offset:cpp.Int64, start_pos:cpp.Pointer<cpp.Int64>, end_pos:cpp.Pointer<cpp.Int64>,
		tstamp:cpp.Pointer<cpp.UInt64>):Bool;

	@:native("offset_seek")
	public function offset_seek(offset:cpp.UInt64):Bool;

	@:native("track_seek")
	public function track_seek(track:cpp.UInt32, tstamp:cpp.Float64):Bool;

	@:native("track_type")
	public function track_type(track:cpp.UInt32):NESTEGG_TRACK;

	@:native("track_codec_id")
	public function track_codec_id(track:cpp.UInt32):NESTEGG_CODEC;

	@:native("track_codec_data_count")
	public function track_codec_data_count(track:cpp.UInt32, count:cpp.Pointer<UInt32>):Bool;

	@:native("track_codec_data")
	public function track_codec_data(track:cpp.UInt32, item:cpp.UInt32, data:Pointer<BytesData>, length:Pointer<SizeT>):Bool;

	@:native("track_video_params")
	public function track_video_params(track:cpp.UInt32, params:cpp.Pointer<VideoParams>):Bool;

	@:native("track_audio_params")
	public function track_audio_params(track:cpp.UInt32, params:cpp.Pointer<AudioParams>):Bool;

	@:native("track_encoding")
	public function track_encoding(track:cpp.UInt32):NESTEGG_ENCODING;

	@:native("track_content_enc_key_id")
	public function track_content_enc_key_id(track:cpp.UInt32, content_enc_key_id:ConstPointer<BytesData>, content_enc_key_id_length:Pointer<SizeT>):Bool;

	@:native("track_default_duration")
	public function track_default_duration(track:cpp.UInt32, duration:cpp.Pointer<UInt64>):Bool;

	@:native("read_reset")
	public function read_reset():Bool;

    @:native("read_packet")
    public function read_packet(packet:Pointer<Packet>):Int;

	@:native("has_cues")
	public function has_cues():Bool;
} // nestegg

@:keep
@:structAccess
@:include('linc_nestegg.h')
@:native("linc::nestegg::packet")
extern class Packet {

	public static inline function init():Pointer<Packet> {
        return untyped  __cpp__("new linc::nestegg::packet()");
    }

	@:native("free")
	public function free():Void;

	@:native("has_keyframe")
	public function has_keyframe():NESTEGG_PACKET_HAS_KEYFRAME;

    @:native("encryption")
    public function encryption():NESTEGG_PACKET_HAS_SIGNAL;

    @:native("track")
    public function track(track:Pointer<cpp.UInt32>):Bool;

    @:native("tstamp")
    public function tstamp(tstamp:Pointer<UInt64>):Bool;

    @:native("duration")
    public function duration(duration:Pointer<cpp.UInt64>):Bool;

    @:native("count")
    public function count(count:Pointer<UInt32>):Bool;

    @:native("data")
    public function data(item:UInt32, data:Pointer<BytesData>, length:Pointer<SizeT>):Bool;

    @:native("additional_data")
    public function additional_data(id:UInt32, data:Pointer<BytesData>, length:Int):Bool;

    @:native("discard_padding")
    public function discard_padding(discard_padding:Pointer<Int64>):Bool;

    @:native("offsets")
    public function offsets(partition_offsets:ConstPointer<Array<UInt32>>, num_offsets:Pointer<UInt8>):Bool;

    @:native("reference_block")
    public function reference_block(reference_block:cpp.Pointer<Int64>):Bool;
}



@:structAccess
@:keep
@:include('linc_nestegg.h')
@:native("linc::nestegg::io_buffer")
extern class IO {
    public var buffer:BytesData;
    public var length:Int;
    public var offset:Int;

    public static inline function init(buffer:BytesData, offset:Int):IO{

        var _io:IO = untyped __cpp__("linc::nestegg::io_buffer{}");
        _io.buffer = buffer;
        _io.length = buffer.length;
        _io.offset = 0;

        return _io;
    }

}

@:structAccess
@:keep
@:include('linc_nestegg.h')
@:native("::nestegg_video_params")
extern class VideoParams {
	public var stereo_mode:cpp.UInt32;
	public var width:cpp.UInt32;
	public var height:cpp.UInt32;
	public var display_width:cpp.UInt32;
	public var display_height:cpp.UInt32;
	public var crop_bottom:cpp.UInt32;
	public var crop_top:cpp.UInt32;
	public var crop_left:cpp.UInt32;
	public var crop_right:cpp.UInt32;
	public var alpha_mode:cpp.UInt32;
	public var matrix_coefficients:cpp.UInt32;
	public var range:cpp.UInt32;
	public var transfer_characteristics:cpp.UInt32;
	public var primaries:cpp.UInt32;

	public var primary_r_chromaticity_x:Float64;
	public var primary_r_chromaticity_y:Float64;
	public var primary_g_chromaticity_x:Float64;
	public var primary_g_chromaticity_y:Float64;

	public var primary_b_chromaticity_x:Float64;
	public var primary_b_chromaticity_y:Float64;

	public var luminance_max:Float64;
	public var luminance_min:Float64;

	public var white_point_chromaticity_x:Float64;
	public var white_point_chromaticity_y:Float64;

    public static inline function init():VideoParams {
        return untyped __cpp__("::nestegg_video_params{}");
    }
}

@:structAccess
@:keep
@:include('linc_nestegg.h')
@:native("::nestegg_audio_params")
extern class AudioParams {
	public var rate:Float64;
	public var channels:cpp.UInt32;
	public var depth:cpp.UInt32;
	public var codec_delay:cpp.UInt64;
	public var seek_preroll:cpp.UInt64;

    public static inline function init():AudioParams {
        return untyped __cpp__("::nestegg_audio_params{}");
    }
}

@:keep
@:include('linc_nestegg.h')
extern enum abstract NESTEGG_TRACK(Int) from Int to Int {
	@:native("NESTEGG_TRACK_VIDEO")
	var VIDEO;
	@:native("NESTEGG_TRACK_AUDIO")
	var AUDIO;
	@:native("NESTEGG_TRACK_UNKNOWN")
	var UNKNOWN;
	var UNDEFINED = -1;
}

@:keep
@:include('linc_nestegg.h')
extern enum abstract NESTEGG_CODEC(Int) from Int to Int {
	@:native("NESTEGG_CODEC_VP8")
	var VP8;
	@:native("NESTEGG_CODEC_VP9")
	var VP9;
	@:native("NESTEGG_CODEC_AV1")
	var AV1;
	@:native("NESTEGG_CODEC_OPUS")
	var OPUS;
	@:native("NESTEGG_CODEC_VORBIS")
	var VORBIS;
	@:native("NESTEGG_CODEC_UNKNOWN")
	var UNKNOWN;
	var UNDEFINED = -1;
}

@:keep
@:include('linc_nestegg.h')
extern enum abstract NESTEGG_ENCODING(Int) from Int to Int {
	@:native("NESTEGG_ENCODING_COMPRESSION")
	var COMPRESSION;
	@:native("NESTEGG_ENCODING_ENCRYPTION")
	var ENCRYPTION;
	var UNDEFINED = -1;
}

enum abstract NESTEGG_PACKET_HAS_KEYFRAME(Int) from Int to Int {
	var FALSE = 0;
	var TRUE = 1;
	var UNKNOWN = 2;
    var ERROR = -1;
}


enum abstract NESTEGG_PACKET_HAS_SIGNAL(Int) from Int to Int {
    var FALSE = 0;
    var UNENCRYPTED  = 1;
    var ENCRYPTED  = 2;
    var PARTITIONED = 4;
    var ERROR = -1;
}