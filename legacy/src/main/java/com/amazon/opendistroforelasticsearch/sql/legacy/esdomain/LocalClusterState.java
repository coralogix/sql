/*
 *   Copyright 2019 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 *   Licensed under the Apache License, Version 2.0 (the "License").
 *   You may not use this file except in compliance with the License.
 *   A copy of the License is located at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *   or in the "license" file accompanying this file. This file is distributed
 *   on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 *   express or implied. See the License for the specific language governing
 *   permissions and limitations under the License.
 */

package com.amazon.opendistroforelasticsearch.sql.legacy.esdomain;

/**
 * Local cluster state information which may be stale but help avoid blocking operation in NIO thread.
 * <p>
 * 1) Why extending TransportAction doesn't work here?
 * TransportAction enforce implementation to be performed remotely but local cluster state read is expected here.
 * <p>
 * 2) Why injection by AbstractModule doesn't work here?
 * Because this state needs to be used across the plugin, ex. in rewriter, pretty formatter etc.
 */
public class LocalClusterState {
    /**
     * Singleton instance
     */
    private static StateProvider INSTANCE;

    public static synchronized StateProvider state() {
        if (INSTANCE == null) {
            INSTANCE = new StateProvider.Cached();
        }
        return INSTANCE;
    }

    /**
     * Give testing code a chance to inject mock object
     */
    public static synchronized void state(StateProvider instance) {
        INSTANCE = instance;
    }
}
