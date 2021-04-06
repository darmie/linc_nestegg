#pragma once

//hxcpp include should always be first
#ifndef HXCPP_H
#include <hxcpp.h>
#endif

//include other library includes as needed
// #include "../lib/____"

#include "../lib/nestegg/include/nestegg/nestegg.h"
#include <stdio.h>

typedef struct nestegg nnestegg;

namespace linc
{

    namespace nestegg
    {

        static void log_callback(::nestegg *ctx, unsigned int severity, char const *fmt, ...);

        /**
         * Three functions that implement the nestegg_io interface, operating on a io_buffer. 
         * */
        struct io_buffer
        {
            //unsigned char const *buffer;
            ::Array<unsigned char> buffer;
            size_t length;
            int64_t offset;
        };

        static int read(void *buffer, size_t length, void *userdata)
        {
            size_t r;
            FILE *fp = static_cast<FILE*>(userdata);

            r = fread(buffer, length, 1, fp);
            if (r == 0 && feof(fp))
                return 0;
            return r == 0 ? -1 : 1;
            // struct io_buffer *iob = static_cast<struct io_buffer *>(userdata);

            // size_t available = iob->length - iob->offset;

            // fprintf(stdout, "available %zu length %zu offset %llu\n", available, iob->length, iob->offset);

            // if (available == 0)
            //     return 0;

            // if (available < length)
            //     return -1;

            // iob->buffer->memcpy(iob->offset, (const unsigned char *)buffer, length);

            // // memcpy(buffer, iob->buffer + iob->offset, length);
            // iob->offset += length;

            // return 1;
        }
        static int64_t tell(void *userdata)
        {
            // struct io_buffer *iob = static_cast<struct io_buffer *>(userdata);
            // return iob->offset;
            return ftell(static_cast<FILE*>(userdata));
        }
        static int seek(int64_t offset, int whence, void *userdata)
        {
            FILE *fp = static_cast<FILE*>(userdata);
            return fseek(fp, offset, whence);
            // fprintf(stdout, "seek %lld\n", offset);
            // struct io_buffer *iob = static_cast<struct io_buffer *>(userdata);
            // fprintf(stdout, "%s\n", iob->buffer->toString().c_str());
            // int64_t o = iob->offset;

            // switch (whence)
            // {
            // case NESTEGG_SEEK_SET:
            //     o = offset;
            //     break;
            // case NESTEGG_SEEK_CUR:
            //     o += offset;
            //     break;
            // case NESTEGG_SEEK_END:
            //     o = iob->length + offset;
            //     break;
            // }

            // if (o < 0 || o > (int64_t)iob->length)
            //     return -1;

            // iob->offset = o;
            // return 0;
        }
        static bool sniff(const unsigned char *buffer, size_t length);

        class packet
        {
        public:
            nestegg_packet *pkt;

            packet() {}

            ~packet()
            {
                nestegg_free_packet(pkt);
            }

            void free()
            {
                nestegg_free_packet(pkt);
            }

            int has_keyframe()
            {
                return nestegg_packet_has_keyframe(pkt);
            }

            bool track(unsigned int *track)
            {
                return nestegg_packet_track(pkt, track) == 0;
            }

            bool tstamp(uint64_t *tstamp)
            {
                return nestegg_packet_tstamp(pkt, tstamp) == 0;
            }

            bool duration(uint64_t *duration)
            {
                return nestegg_packet_duration(pkt, duration) == 0;
            }

            bool count(unsigned int *count)
            {
                return nestegg_packet_count(pkt, count) == 0;
            }

            bool data(unsigned int item,
                      ::cpp::Pointer<Array<unsigned char>> data, size_t *length)
            {
                unsigned char *_data = (unsigned char *)data.get_raw()->mPtr->getBase();
                int ret = nestegg_packet_data(pkt, item, &_data, length);
                data.set_ref(Array_obj<unsigned char>::fromData(_data, *length));
                return ret == 0;
            }

            bool additional_data(unsigned int id,
                                 unsigned char **data, size_t *length)
            {
                return nestegg_packet_additional_data(pkt, id, data, length) == 0;
            }

            bool discard_padding(int64_t *discard_padding)
            {
                return nestegg_packet_discard_padding(pkt, discard_padding) == 0;
            }

            int encryption()
            {
                return nestegg_packet_encryption(pkt);
            }

            bool offsets(uint32_t const **partition_offsets,
                         uint8_t *num_offsets)
            {
                return nestegg_packet_offsets(pkt,
                                              partition_offsets,
                                              num_offsets) == 0;
            }

            bool reference_block(int64_t *reference_block)
            {
                return nestegg_packet_reference_block(pkt, reference_block) == 0;
            }
        };

        class nestegg
        {
        private:
            nnestegg *ctx;

        public:
            nestegg(::String path, int64_t max_offset = -1)
            {
                FILE *fp;
                ::nestegg_io io;
                io.read = linc::nestegg::read;
                io.seek = linc::nestegg::seek;
                io.tell = linc::nestegg::tell;

                fp = fopen(path, "rb");
                if (!fp)
                    EXIT_FAILURE;

                io.userdata = fp;

                int r = nestegg_init(&ctx, io, NULL, -1);

                if (r != 0)
                {
                    EXIT_FAILURE;
                }
            }
            ~nestegg()
            {
                nestegg_destroy(ctx);
            }

            bool duration(uint64_t *duration)
            {
                return nestegg_duration(ctx, duration) == 0;
            }
            bool tstamp_scale(uint64_t *scale)
            {
                return nestegg_tstamp_scale(ctx, scale) == 0;
            }
            bool track_count(unsigned int *tracks)
            {
                //fprintf(stdout,"%b", ctx == nullptr);
                return nestegg_track_count(ctx, tracks) == 0;
            }

            bool get_cue_point(unsigned int cluster_num,
                               int64_t max_offset, int64_t *start_pos,
                               int64_t *end_pos, uint64_t *tstamp)
            {
                return nestegg_get_cue_point(ctx, cluster_num, max_offset, start_pos, end_pos, tstamp) == 0;
            }

            bool offset_seek(uint64_t offset)
            {
                return nestegg_offset_seek(ctx, offset) == 0;
            }

            bool track_seek(unsigned int track, uint64_t tstamp)
            {
                return nestegg_track_seek(ctx, track, tstamp) == 0;
            }

            int track_type(unsigned int track)
            {
                return nestegg_track_type(ctx, track);
            }

            int track_codec_id(unsigned int track)
            {
                return nestegg_track_codec_id(ctx, track);
            }

            bool track_codec_data_count(unsigned int track,
                                        unsigned int *count)
            {
                return nestegg_track_codec_data_count(ctx, track, count) == 0;
            }

            bool track_codec_data(unsigned int track, unsigned int item,
                                  ::cpp::Pointer<Array<unsigned char>> data, size_t *length)
            {
                
                unsigned char *_data = (unsigned char *)data.get_raw()->mPtr->getBase();
                int ret = nestegg_track_codec_data(ctx, track, item, &_data, length);
                data.set_ref(Array_obj<unsigned char>::fromData(_data, *length));
                return ret == 0;
            }

            bool track_video_params(unsigned int track,
                                    nestegg_video_params *params)
            {
                return nestegg_track_video_params(ctx, track, params) == 0;
            }

            bool track_audio_params(unsigned int track,
                                    nestegg_audio_params *params)
            {
                return nestegg_track_audio_params(ctx, track, params) == 0;
            }

            int track_encoding(unsigned int track)
            {
                return nestegg_track_encoding(ctx, track);
            }

            bool track_content_enc_key_id(unsigned int track,
                                          unsigned char const **content_enc_key_id,
                                          size_t *content_enc_key_id_length)
            {
                return nestegg_track_content_enc_key_id(ctx, track, content_enc_key_id, content_enc_key_id_length) == 0;
            }

            bool track_default_duration(unsigned int track, uint64_t *duration)
            {
                return nestegg_track_default_duration(ctx, track, duration) == 0;
            }

            bool read_reset()
            {
                return nestegg_read_reset(ctx) == 0;
            }

            int read_packet(::cpp::Pointer<linc::nestegg::packet> _packet)
            {
                return nestegg_read_packet(ctx, &(_packet->get_ref().pkt));
            }

            bool has_cues()
            {
                return nestegg_has_cues(ctx) == 1;
            }

        }; //nestegg class

        static bool sniff(const unsigned char *buffer, size_t length)
        {
            return nestegg_sniff(buffer, length) == 0;
        }

        static void log_callback(::nestegg *ctx, unsigned int severity, char const *fmt, ...)
        {
            va_list ap;
            char const *sev = NULL;

#if !defined(DEBUG)
            if (severity < NESTEGG_LOG_WARNING)
                return;
#endif

            switch (severity)
            {
            case NESTEGG_LOG_DEBUG:
                sev = "debug:   ";
                break;
            case NESTEGG_LOG_WARNING:
                sev = "warning: ";
                break;
            case NESTEGG_LOG_CRITICAL:
                sev = "critical:";
                break;
            default:
                sev = "unknown: ";
            }

            fprintf(stderr, "%p %s ", (void *)ctx, sev);

            va_start(ap, fmt);
            vfprintf(stderr, fmt, ap);
            va_end(ap);

            fprintf(stderr, "\n");
        }
    } // namespace nestegg

} //linc