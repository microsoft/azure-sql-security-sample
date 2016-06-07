using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;

namespace ContosoClinic.Models
{
    public class Patient
    {
        public Patient() { }
        public int PatientID { get; set; }

        [StringLength(11)]
        [Column(TypeName = "char")]
        [Required]
        public string SSN { get; set; }

        [StringLength(50)]
        public string FirstName { get; set; }

        [StringLength(50)]
        [Required]
        public string LastName { get; set; }

        [StringLength(50)]
        public string MiddleName { get; set; }

        [StringLength(50)]
        [Required]
        public string StreetAddress { get; set; }

        [StringLength(50)]
        [Required]
        public string City { get; set; }

        [StringLength(5)]
        [Column(TypeName = "char")]
        [Required]
        public string ZipCode { get; set; }

        [StringLength(2)]
        [Column(TypeName = "char")]
        [Required]
        public string State { get; set; }

        [Column(TypeName = "date")]
        [Required]
        public System.DateTime BirthDate { get; set; }

        public virtual ICollection<Visit> Visits { get; set; }
        public virtual ICollection<ApplicationUser> ApplicationUsers { get; set; }
    }

    public class Visit
    {
        public int VisitID { get; set; }

        [Required]
        public int PatientID { get; set; }

        [Column(TypeName = "date")]
        [Required]
        public System.DateTime Date { get; set; }

        [StringLength(4000)]
        [Required]
        public string Reason { get; set; }

        [StringLength(4000)]
        [Required]
        public string Treatment { get; set; }
        [Column(TypeName = "date")]
        public Nullable<System.DateTime> FollowUpDate { get; set; }

        public virtual Patient Patient { get; set; }
    }
}