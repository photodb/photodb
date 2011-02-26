using System;
using System.Linq;
using System.Web;

namespace PhotoDBDatabase.Classes
{
    public class StatsManager : BaseManager
    {
        public static int HostId
        {
            get
            {
                int? hostId = (int?)HttpContext.Current.Items["HOST_ID"];
                if (hostId.HasValue)
                    return hostId.Value;

                string userAgent = UserAgent;
                if (userAgent.Length > 250)
                    userAgent = userAgent.Substring(0, 250);

                using (SiteDatabaseDataContext db = new SiteDatabaseDataContext(ConnectionString))
                {
                    var hosts = from h in db.Hosts
                                where h.HostName == ClientIp && h.HostDescription == userAgent
                                select h;

                    foreach (Host host in hosts)
                    {
                        HttpContext.Current.Items["HOST_ID"] = host.HostId;
                        return host.HostId;
                    }

                    Host newHost = new Host { HostName = ClientIp, HostDescription = userAgent };
                    db.Hosts.InsertOnSubmit(newHost);
                    db.SubmitChanges();

                    HttpContext.Current.Items["HOST_ID"] = newHost.HostId;
                    return newHost.HostId;
                }
            }
        }

        public static string CurrentReferer
        {
            get
            {
                string referer = String.Empty;
                if (HttpContext.Current.Request.UrlReferrer != null)
                    referer = HttpContext.Current.Request.UrlReferrer.AbsoluteUri ?? String.Empty;
                if (String.IsNullOrEmpty(referer))
                    referer = HttpContext.Current.Request.ServerVariables["HTTP_REFERER"] ?? String.Empty;
                return referer;
            }
        }

        public static int CurrentRefererId
        {
            get
            {
                int? referId = (int?)HttpContext.Current.Items["REFER_ID"];
                if (referId.HasValue)
                    return referId.Value;
                
                referId = CheckRefer();
                HttpContext.Current.Items["REFER_ID"] = referId.Value;
                return referId.Value;
            }
        }

        public static int CheckRefer()
        {
            return AddNewRefer(CurrentReferer);
        }

        private static int AddNewRefer(string referUrl)
        {
            using (SiteDatabaseDataContext db = new SiteDatabaseDataContext(ConnectionString))
            {
                Refer refer = db.Refers.Where(x => x.ReferUrl.ToUpper() == referUrl.ToUpper()).FirstOrDefault();
                if (refer == null)
                {
                    refer = new Refer();
                    refer.DateCreate = DateTime.Now;
                    refer.DateUpdate = DateTime.Now;
                    refer.ReferCount = 1;
                    refer.ReferUrl = referUrl;
                    db.Refers.InsertOnSubmit(refer);
                }
                else
                {
                    refer.ReferCount = refer.ReferCount + 1;
                    refer.DateUpdate = DateTime.Now;
                }
                db.SubmitChanges();
                return refer.ReferId;
            }
        }
    }
}
