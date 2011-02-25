using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Configuration;

namespace PhotoDBDatabase.Classes
{
    public static class DownloadManager
    {
        public static string ConnectionString
        {
            get
            {
                return ConfigurationManager.AppSettings["SiteDatabase"];            
            }
        }

        public static int GetDownloadCount(int mediaId)
        {
            using (SiteDatabaseDataContext db = new SiteDatabaseDataContext(ConnectionString))
            {
                var result = from d in db.Downloads
                             where d.MediaId == mediaId
                             select 1;

                return result.Count();
            }
        }

        public static void NewDownload(int mediaId, int pageId, string requestUrl, string downloadUrl)
        {
            using (SiteDatabaseDataContext db = new SiteDatabaseDataContext(ConnectionString))
            {
                /*Download d = new Download()
                {
                    DownloadDate = DateTime.Now,
                    DownloadPageId = pageId,
                    DownloadUrl = downloadUrl,
                    RequestedUrl = requestUrl,
                    MediaId = mediaId,
                    ReferId = 0,
                    HostId = 0,
                };
                db.Downloads.InsertOnSubmit(d);
                db.SubmitChanges();*/
            }
        }
    }
}
