/*
   Copyright 2009 Zepheira LLC

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

 */
package org.callimachusproject.rdfa.events;

public class BuiltInCall extends Filter {
	private String function;

	public BuiltInCall(boolean start, String function) {
		super(start);
		this.function = function;
	}

	public String getFunction() {
		return function;
	}

	public String toString() {
		if (isStart())
			return function + "(";
		return ")";
	}
}
