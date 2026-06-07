using System.ComponentModel.DataAnnotations;

namespace HiSUP.Models
{
    public class AuditLog
    {
        [Key] public int LogID { get; set; }
        [Required, MaxLength(50)]  public string TableName { get; set; } = string.Empty;
        [Required, MaxLength(10)]  public string Operation { get; set; } = string.Empty;
        public string? OldValue { get; set; }
        public string? NewValue { get; set; }
        [Required, MaxLength(100)] public string DBUser { get; set; } = string.Empty;
        public DateTime LoggedAt { get; set; } = DateTime.Now;
    }
}
