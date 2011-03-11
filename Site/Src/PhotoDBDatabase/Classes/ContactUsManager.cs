
namespace PhotoDBDatabase.Classes
{
    public class ContactUsManager : BaseManager
    {
        public static bool LeaveMessage(string firstName, string lastName, string email, string organization,
            string theme, string text)
        {
            using (SiteDatabaseDataContext db = new SiteDatabaseDataContext(ConnectionString))
            {
                Contact contact = new Contact()
                {
                    FirstName = firstName,
                    LastName = lastName,
                    Email = email,
                    Organization = organization,
                    Theme = theme,
                    Text = text,
                    HostId = StatsManager.HostId,
                    ContactMode = "CONTACTUS",
                };
                db.Contacts.InsertOnSubmit(contact);
                db.SubmitChanges();
                return true;
            }
        }
    }
}
