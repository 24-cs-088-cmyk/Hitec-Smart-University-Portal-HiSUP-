using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace HiSUP.Models
{
    public class FeePayment
    {
        [Key] public int PaymentID { get; set; }
        [Required] public int StudentID { get; set; }
        [Required] public int FeeStructureID { get; set; }
        [Required] public decimal AmountPaid { get; set; }
        public DateTime PaymentDate { get; set; } = DateTime.Now;
        public byte[]? BankAccount { get; set; }
        [MaxLength(20)] public string Status { get; set; } = "Paid";
        [MaxLength(50)] public string? ReferenceNo { get; set; }
        [ForeignKey("StudentID")]      public Student?      Student      { get; set; }
        [ForeignKey("FeeStructureID")] public FeeStructure? FeeStructure { get; set; }
    }
}
