using System;
using System.Net.Mail;
using System.Text;
using System.Web;
using System.Net;
using System.Configuration;

namespace PhotoDBUmbracoExtensions
{
    public static class Mailer
    {
        public static void MailNotify(string subject, MailData data)
        {
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("PhotoDB site notify:");
            sb.AppendLine("Page: " + HttpContext.Current.Request.Url.OriginalString);
            sb.AppendLine();
            sb.AppendLine("Data:");
            sb.AppendLine();
            sb.AppendLine(data.BuildData("{0} - {1}" + Environment.NewLine));

            MailMessage mm = new MailMessage(
                UmbracoSettings.FromEmail,
                UmbracoSettings.Mailto,
                String.Format("{0}: {1}", UmbracoSettings.SubjectText, subject),
                sb.ToString());

            using (SmtpClient client = new SmtpClient(UmbracoSettings.SMTPServer,
                UmbracoSettings.SMTPPort))
            {
                try
                {
                    client.Credentials = new NetworkCredential(ConfigurationManager.AppSettings["SMTPUser"],
                        ConfigurationManager.AppSettings["SMTPPassword"]);
                    client.Send(mm);
                }
                catch
                { }
            }
        }
    }
}
