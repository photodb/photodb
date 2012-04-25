using System;
using System.Linq;

namespace PhotoDBDatabase.Classes
{
    public class DownloadManager : BaseManager
    {
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

        public static bool NewDownload(int mediaId, int pageId, string requestUrl, string downloadUrl, string countryCode)
        {
            using (SiteDatabaseDataContext db = new SiteDatabaseDataContext(ConnectionString))
            {
                Download lastDownload = db.Downloads.OrderBy(x => -x.DownloadId).FirstOrDefault();
                if (lastDownload != null && lastDownload.HostId == StatsManager.HostId)
                    return false;

                Download d = new Download()
                {
                    DownloadDate = DateTime.Now,
                    DownloadPageId = pageId,
                    DownloadUrl = downloadUrl,
                    RequestedUrl = requestUrl,
                    MediaId = mediaId,
                    ReferId = StatsManager.CurrentRefererId,
                    HostId = StatsManager.HostId,
                    CountryCode = countryCode,
                };
                db.Downloads.InsertOnSubmit(d);
                db.SubmitChanges();

                return true;
            }
        }
    }
}
