package;

import sys.FileSystem;
import cpp.Pointer;
import cpp.UInt64;
import haxe.io.Path;
import cpp.UInt32;
import cpp.SizeT;
import nestegg.Nestegg;
import haxe.io.BytesData;

using StringTools;

class Test {
	static function main() {
		var files = FileSystem.readDirectory(Path.join([Sys.getCwd(), "media"]));

		for (f in files) {
			if (f.startsWith("bug"))
				continue;
			if (f.endsWith("ok"))
				continue;
			dump(Path.join(["media", f]));
		}
	}

	static function dump(path:String) {
		Sys.println("");
		Sys.println(Path.join([Sys.getCwd(), path]));
		var type:Null<NESTEGG_TRACK>;
		var aparams:AudioParams = AudioParams.init();
		var vparams:VideoParams = VideoParams.init();
		var packet:Pointer<Packet> = Packet.init();
		var size:SizeT = 0;
		var length:SizeT = 0;

		var duration:UInt64 = 0;
		var tstamp:UInt64 = 0;
		var pkt_tstamp:UInt64 = 0;
		var codec_data:BytesData = [];
		var ptr:BytesData = [];

		var cnt:UInt32 = 0,
			i:UInt32 = 0,
			j:UInt32 = 0,
			track:UInt32 = 0,
			tracks:UInt32 = 0,
			pkt_cnt:UInt32 = 0,
			pkt_track:UInt32 = 0;

		var data_items:UInt32 = 0;

		var nestegg = Nestegg.init(Path.join([Sys.getCwd(), path]), -1).ref;
		nestegg.track_count(cpp.Pointer.addressOf(tracks));

		if (nestegg.duration(cpp.Pointer.addressOf(duration))) {
			Sys.println('media has ${tracks} tracks and duration ${duration / 1e9}s');
		} else {
			Sys.println('media has ${tracks} tracks and and unknown duration, using 10s default ');
			duration = cast 10000000000;
		}

		for (i in 0...tracks) {
			type = nestegg.track_type(i);
			var _type = switch type {
				case AUDIO: "AUDIO";
				case VIDEO: "VIDEO";
				case UNKNOWN: "UNKNOWN";
				case UNDEFINED: "UNDEFINED";
			}

			var codec_id = switch nestegg.track_codec_id(i) {
				case AV1: "AV1";
				case OPUS: "OPUS";
				case VORBIS: "VORBIS";
				case VP8: "VP8";
				case VP9: "VP9";
				case UNKNOWN: "UNKNOWN";
				case UNDEFINED: "UNDEFINED";
			}

			Sys.println('track ${i}: type: ${_type} codec: ${codec_id}');

			nestegg.track_codec_data_count(i, Pointer.addressOf(data_items));

			for (j in 0...data_items) {
				nestegg.track_codec_data(i, j, Pointer.addressOf(codec_data), Pointer.addressOf(length));
				var _length:Int = cast length;
				Sys.println(' (${codec_data}, ${_length})');
			}
			if (type == VIDEO) {
				nestegg.track_video_params(i, Pointer.addressOf(vparams));
				Sys.println(' video: ${vparams.width}x${vparams.height} (d: ${vparams.display_width}x${vparams.display_height} ${vparams.crop_top}x${vparams.crop_left}x${vparams.crop_bottom}x${vparams.crop_right})');
			} else if (type == AUDIO) {
				nestegg.track_audio_params(i, Pointer.addressOf(aparams));
				Sys.println(' audio: ${aparams.rate}hz ${aparams.depth} bit ${aparams.channels} channels');
			}
			Sys.println("");
		}
		Sys.println("seek to middle");
		if (nestegg.track_seek(0, duration / 2)) {
			Sys.print("middle ");
			var r = nestegg.read_packet(packet);
			if (r == 1) {
				packet.ref.track(Pointer.addressOf(track));
				packet.ref.count(Pointer.addressOf(cnt));
				packet.ref.tstamp(Pointer.addressOf(tstamp));
				Sys.println('* t ${track} pts ${tstamp / 1e9} frames ${cnt}');
				packet.ref.free();
			}
		} else {
			Sys.println("middle seek failed");
		}
		Sys.println("seek to end");
		if (nestegg.track_seek(0, duration - (duration / 10))) {
			Sys.print("end ");
			var r = nestegg.read_packet(packet);
			if (r == 1) {
				packet.ref.track(Pointer.addressOf(track));
				packet.ref.count(Pointer.addressOf(cnt));
				packet.ref.tstamp(Pointer.addressOf(tstamp));
				Sys.println('* t ${track} pts ${tstamp / 1e9} frames ${cnt}');
				packet.ref.free();
			}
		} else {
			Sys.println("end seek failed");
		}
		Sys.println("seek to start");
		if (nestegg.track_seek(0, (duration / 10))) {
			Sys.print("start ");
			var r = nestegg.read_packet(packet);
			if (r == 1) {
				packet.ref.track(Pointer.addressOf(track));
				packet.ref.count(Pointer.addressOf(cnt));
				packet.ref.tstamp(Pointer.addressOf(tstamp));
				Sys.println('* t ${track} pts ${tstamp / 1e9} frames ${cnt}');
				packet.ref.free();
			}
		} else {
			Sys.println("start seek failed");
		}

		while (nestegg.read_packet(packet) == 1) {
			packet.ref.track(Pointer.addressOf(pkt_track));
			packet.ref.count(Pointer.addressOf(pkt_cnt));
			packet.ref.tstamp(Pointer.addressOf(pkt_tstamp));

            Sys.print('t ${pkt_track} pts ${pkt_tstamp / 1e9} frames ${pkt_cnt}: ');

            for(i in 0...pkt_cnt){
                packet.ref.data(i, Pointer.addressOf(ptr), Pointer.addressOf(size));
                var _size:Int = cast size;
                Sys.print('${_size}');
            }

            Sys.println("");
            packet.ref.free();
		}
	}
}
