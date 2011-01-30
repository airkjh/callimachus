/*
 * Portions Copyright (c) 2009-10 Zepheira LLC and James Leigh, Some
   Rights Reserved
 * Portions Copyright (c) 2010-11 Talis Inc, Some Rights Reserved 
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */
package org.callimachusproject.logging;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.Enumeration;
import java.util.logging.Formatter;
import java.util.logging.Handler;
import java.util.logging.Level;
import java.util.logging.LogManager;
import java.util.logging.LogRecord;
import java.util.logging.Logger;

import javax.management.Notification;
import javax.management.NotificationBroadcasterSupport;

/**
 * MXBean to control jdk logging using a simple interface.
 * 
 * @author James Leigh
 *
 */
public class LoggerBean extends NotificationBroadcasterSupport implements
		LoggerMXBean {
	private Formatter formatter;
	private Handler nh;

	public final class NotificationHandler extends Handler {

		@Override
		public void publish(LogRecord record) {
			String type = record.getLevel().toString();
			String source = record.getLoggerName();
			long sequenceNumber = record.getSequenceNumber();
			long timeStamp = record.getMillis();
			if (source.startsWith("javax.management") || source.startsWith("sun.rmi"))
				return; // recursive
			String message = getFormatter().formatMessage(record);
			Notification note = new Notification(type, source, sequenceNumber,
					timeStamp, message);
			if (record.getThrown() != null) {
				try {
					StringWriter sw = new StringWriter();
					PrintWriter pw = new PrintWriter(sw);
					record.getThrown().printStackTrace(pw);
					pw.close();
					note.setUserData(sw.toString());
				} catch (Exception ex) {
				}
			}
			sendNotification(note);
		}

		@Override
		public void close() throws SecurityException {
			// no-op
		}

		@Override
		public void flush() {
			// no-op
		}

	}

	public LoggerBean() {
		formatter = new LogMessageFormatter();
		nh = new NotificationHandler();
		nh.setFormatter(formatter);
		nh.setLevel(Level.ALL);
	}

	@Override
	public void startNotifications(String fragment) {
		boolean found = false;
		Enumeration<String> names = LogManager.getLogManager().getLoggerNames();
		while (names.hasMoreElements()) {
			String name = names.nextElement();
			if (name.contains(fragment)) {
				Logger logger = Logger.getLogger(name);
				logger.removeHandler(nh);
				logger.addHandler(nh);
				found = true;
			}
		}
		if (!found)
			throw new IllegalArgumentException("Not such logger");
	}

	@Override
	public void stopNotifications() {
		Enumeration<String> names = LogManager.getLogManager().getLoggerNames();
		while (names.hasMoreElements()) {
			String name = names.nextElement();
			Logger.getLogger(name).removeHandler(nh);
		}
	}

	@Override
	public void logAll(String fragment) {
		boolean found = false;
		Enumeration<String> names = LogManager.getLogManager().getLoggerNames();
		while (names.hasMoreElements()) {
			String name = names.nextElement();
			if (name.contains(fragment)) {
				Logger.getLogger(name).setLevel(Level.ALL);
				found = true;
			}
		}
		if (!found)
			throw new IllegalArgumentException("Not such logger");
	}

	@Override
	public void logInfo(String fragment) {
		boolean found = false;
		Enumeration<String> names = LogManager.getLogManager().getLoggerNames();
		while (names.hasMoreElements()) {
			String name = names.nextElement();
			if (name.contains(fragment)) {
				Logger.getLogger(name).setLevel(Level.INFO);
				found = true;
			}
		}
		if (!found)
			throw new IllegalArgumentException("Not such logger");
	}

	@Override
	public void logWarn(String fragment) {
		boolean found = false;
		Enumeration<String> names = LogManager.getLogManager().getLoggerNames();
		while (names.hasMoreElements()) {
			String name = names.nextElement();
			if (name.contains(fragment)) {
				Logger.getLogger(name).setLevel(Level.WARNING);
				found = true;
			}
		}
		if (!found)
			throw new IllegalArgumentException("Not such logger");
	}

}
