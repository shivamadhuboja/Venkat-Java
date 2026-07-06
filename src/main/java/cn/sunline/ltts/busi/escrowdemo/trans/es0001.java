package cn.sunline.ltts.busi.escrowdemo.trans;

import cn.sunline.aps.common.logging.BizLog;
import cn.sunline.aps.common.logging.BizLogUtil;
import cn.sunline.ltts.busi.escrowdemo.trans.intf.Es0001;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.time.format.DateTimeFormatter;
import java.util.Locale;
import java.util.UUID;

/** Software Escrow 托管登记交易实现。 */
public final class es0001 {

    private static final BizLog BIZ_LOG = BizLogUtil.getBizLog(es0001.class);

    public es0001() {
    }

    public static void registerDeposit(
            final Es0001.Input input,
            final Es0001.Property property,
            final Es0001.Output output) {

        requireText(input.getEscrow_id(), "escrow_id");
        requireText(input.getDepositor(), "depositor");
        requireText(input.getArtifact_name(), "artifact_name");
        requireText(input.getArtifact_version(), "artifact_version");

        String receiptNo = "ESC-" + UUID.randomUUID().toString()
                .replace("-", "")
                .substring(0, 16)
                .toUpperCase(Locale.ROOT);

        output.setReceipt_no(receiptNo);
        output.setStatus("ACCEPTED");
        output.setAccepted_at(OffsetDateTime.now(ZoneOffset.UTC)
                .format(DateTimeFormatter.ISO_OFFSET_DATE_TIME));
        output.setMessage("Artifact " + input.getArtifact_name() + ":" + input.getArtifact_version()
                + " accepted for escrow " + input.getEscrow_id());

        BIZ_LOG.info("Escrow deposit accepted, escrowId={}, receiptNo={}",
                input.getEscrow_id(), receiptNo);
    }

    private static void requireText(String value, String field) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException(field + " must not be blank");
        }
    }
}
