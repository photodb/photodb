using System;
using System.IO;
using System.Web;
using PhotoDBDatabase.Classes;

namespace PhotoDBXsltExtensions
{
    public class Plib
    {
        public static int GetDownloadCount(int mediaId)
        {
            return DownloadManager.GetDownloadCount(mediaId);
        }

        public static int GetFileSize(string fileName)
        {
            string filePath = HttpContext.Current.Server.MapPath(fileName);
            try
            {
                FileInfo fileInfo = new FileInfo(filePath);
                return (int)fileInfo.Length;
            }
            catch
            {
                return -1;
            }
        }

        public static string FormatFileSize(int fileSize, string mbText)
        {
            return String.Format("{0} {1}", (fileSize / (1024.0 * 1024.0)).ToString("0.00"), mbText);
        }
    }
}
