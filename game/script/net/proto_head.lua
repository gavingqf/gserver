--[[
    protocol head describle as follows(c language):

    // head declaration:
    #pragma pack(push,1)
    struct SCliProHead {
	  uint16  wMark;         // mark
	  uint16  wCheckSum;     // checksum
	  uint16  wDataLen;      // data len: 64k is the max length
	  uint16  wDummy;        // dummy data.
   };
   #pragma pack(pop)

   // build head method:
   static void BuildHead(struct SCliProHead &stHead) {
       stHead.wDataLen    = htons(wLen);                       
       stHead.wMark       = htons(MARK);                       
       stHead.wCheckSum   = htons(((wLen) ^ 0xAABB) & 0x88AA); 
   }

   ===========================================
   proto format: SCliProHead + msg_id + proto
   ===========================================
]]