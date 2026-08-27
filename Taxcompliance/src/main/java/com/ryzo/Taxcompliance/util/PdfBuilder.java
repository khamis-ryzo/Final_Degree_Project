package com.ryzo.Taxcompliance.util;

import java.io.ByteArrayOutputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

public final class PdfBuilder {

    private PdfBuilder() {
    }

    public static byte[] simpleDocument(String title, List<String> lines) {
        byte[] content = buildContent(title, lines);

        List<byte[]> objects = new ArrayList<>();
        objects.add("<< /Type /Catalog /Pages 2 0 R >>".getBytes(StandardCharsets.ISO_8859_1));
        objects.add("<< /Type /Pages /Kids [3 0 R] /Count 1 >>".getBytes(StandardCharsets.ISO_8859_1));
        objects.add(("<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Contents 4 0 R "
                + "/Resources << /Font << /F1 5 0 R >> >> >>").getBytes(StandardCharsets.ISO_8859_1));
        objects.add(("<< /Length " + content.length + " >>\nstream\n"
                + new String(content, StandardCharsets.ISO_8859_1) + "\nendstream").getBytes(StandardCharsets.ISO_8859_1));
        objects.add("<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>".getBytes(StandardCharsets.ISO_8859_1));

        ByteArrayOutputStream doc = new ByteArrayOutputStream();
        write(doc, "%PDF-1.4\n");

        List<Integer> offsets = new ArrayList<>();
        for (int i = 0; i < objects.size(); i++) {
            offsets.add(doc.size());
            write(doc, (i + 1) + " 0 obj\n");
            write(doc, objects.get(i));
            write(doc, "\nendobj\n");
        }

        int xrefOffset = doc.size();
        write(doc, "xref\n0 " + (objects.size() + 1) + "\n");
        write(doc, "0000000000 65535 f \n");
        for (Integer offset : offsets) {
            write(doc, String.format("%010d 00000 n \n", offset));
        }
        write(doc, "trailer\n<< /Size " + (objects.size() + 1) + " /Root 1 0 R >>\n");
        write(doc, "startxref\n" + xrefOffset + "\n%%EOF\n");

        return doc.toByteArray();
    }

    private static byte[] buildContent(String title, List<String> lines) {
        StringBuilder content = new StringBuilder();
        content.append("BT\n")
                .append("/F1 16 Tf\n")
                .append("50 760 Td\n")
                .append("(").append(escape(title)).append(") Tj\n")
                .append("/F1 11 Tf\n")
                .append("0 -28 Td\n");
        for (String line : lines) {
            content.append("(").append(escape(line)).append(") Tj\n")
                    .append("0 -18 Td\n");
        }
        content.append("ET\n");
        return content.toString().getBytes(StandardCharsets.ISO_8859_1);
    }

    private static String escape(String text) {
        return (text == null ? "" : text)
                .replace("\\", "\\\\")
                .replace("(", "\\(")
                .replace(")", "\\)");
    }

    private static void write(ByteArrayOutputStream out, String value) {
        write(out, value.getBytes(StandardCharsets.ISO_8859_1));
    }

    private static void write(ByteArrayOutputStream out, byte[] value) {
        out.writeBytes(value);
    }
}
