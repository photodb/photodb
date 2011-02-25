using PhotoDBDatabase.Classes;

namespace PhotoDBXsltExtensions
{
    public class Plib
    {
        public static int GetDownloadCount(int mediaId)
        {
            return DownloadManager.GetDownloadCount(mediaId);
        }
    }
}
