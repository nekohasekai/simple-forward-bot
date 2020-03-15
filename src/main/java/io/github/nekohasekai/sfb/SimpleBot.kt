package io.github.nekohasekai.sfb

import nekox.TdLoader
import nekox.core.*
import nekox.core.client.TdCliClient
import nekox.core.client.TdException
import nekox.core.raw.getChat
import nekox.core.raw.getUser
import nekox.core.utils.makeForward
import td.TdApi
import kotlin.system.exitProcess

object SimpleBot {

    @JvmStatic
    fun main(args: Array<String>) {

        val forwardTo = args[0].toLong()
        val from = args.shift().map { it.toLong() }

        defaultLog.info("from $from forward to $forwardTo")

        TdLoader.tryLoad()

        object : TdCliClient() {

            override suspend fun onAuthorizationFailed(ex: TdException) {

                defaultLog.error("被登出")

                exitProcess(100)

            }

            override suspend fun onNewMessage(userId: Int, chatId: Long, message: TdApi.Message) {

                super.onNewMessage(userId, chatId, message)

                if ((userId == me.id && message.text != "!_fwd_test") || chatId !in from) return

                println("${getUser(userId).displayName} ${message.text}")

                sudo makeForward message syncTo forwardTo

            }

        }.start()

    }

}