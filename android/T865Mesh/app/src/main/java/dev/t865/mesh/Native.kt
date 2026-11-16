package dev.t865.mesh

import org.json.JSONObject

object Native {
    init { System.loadLibrary("t865_mesh") }
    @JvmStatic external fun command(json: String): String
    fun call(op: String, vararg fields: Pair<String, Any>): JSONObject {
        val input = JSONObject().put("op", op)
        fields.forEach { (k, v) -> input.put(k, v) }
        val result = JSONObject(command(input.toString()))
        if (!result.optBoolean("ok")) throw IllegalStateException(result.optString("error"))
        return result
    }
    fun hex(bytes: ByteArray) = bytes.joinToString("") { "%02x".format(it.toInt() and 255) }
    fun unhex(hex: String): ByteArray = hex.chunked(2).map { it.toInt(16).toByte() }.toByteArray()
}
