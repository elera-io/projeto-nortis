global class LeadResponseDTO {

    global String message;
    global String status;
    private String lead_id;

    global LeadResponseDTO() {}
    
    public LeadResponseDTO(String message, Boolean isSuccess, String lead_id) {
        this.message = message;
        this.status = isSuccess ? 'sucesso' : 'erro';
        this.lead_id = lead_id;
    }

    public LeadResponseDTO(String message, Boolean isSuccess) {
        this.message = message;
        this.status = isSuccess ? 'sucesso' : 'erro';
    }
}