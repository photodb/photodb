using System;

namespace PhotoDBDatabase.Classes
{
    public class ActivationManager : BaseManager
    {
        public static void NewFreeActivation(string firstName, string lastName, string email, string phone, string country, string city, string address,
            string programCode, string activationCode, string programVersion, bool isFull)
        {
            using (SiteDatabaseDataContext db = new SiteDatabaseDataContext(ConnectionString))
            {
                Activation a = new Activation()
                {
                    FirstName = firstName,
                    LastName = lastName,
                    Email = email,
                    Phone = phone,
                    Country = country,
                    City = city,
                    Address = address,
                    ActivationMode = isFull ? "FULL" : "FREE",
                    ProgramCode = programCode,
                    ActivationCode = activationCode,
                    ActivationDate = DateTime.Now,
                    HostId = StatsManager.HostId,
                    ProgramVersion = programVersion,
                };
                db.Activations.InsertOnSubmit(a);
                db.SubmitChanges();
            }
        }
    }
}
