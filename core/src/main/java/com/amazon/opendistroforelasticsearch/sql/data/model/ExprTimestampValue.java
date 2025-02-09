/*
 *
 *    Copyright 2020 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 *    Licensed under the Apache License, Version 2.0 (the "License").
 *    You may not use this file except in compliance with the License.
 *    A copy of the License is located at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    or in the "license" file accompanying this file. This file is distributed
 *    on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 *    express or implied. See the License for the specific language governing
 *    permissions and limitations under the License.
 *
 */

package com.amazon.opendistroforelasticsearch.sql.data.model;

import com.amazon.opendistroforelasticsearch.sql.data.type.ExprCoreType;
import com.amazon.opendistroforelasticsearch.sql.data.type.ExprType;
import com.amazon.opendistroforelasticsearch.sql.exception.SemanticCheckException;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.time.temporal.ChronoUnit;
import java.util.Objects;
import lombok.EqualsAndHashCode;
import lombok.RequiredArgsConstructor;

/**
 * Expression Timestamp Value.
 */
@RequiredArgsConstructor
public class ExprTimestampValue extends AbstractExprValue {
  /**
   * todo. only support UTC now.
   */
  private static final ZoneId ZONE = ZoneId.of("UTC");
  /**
   * todo. only support timestamp in format yyyy-MM-dd HH:mm:ss.
   */
  private static final DateTimeFormatter FORMATTER = DateTimeFormatter
      .ofPattern("yyyy-MM-dd HH:mm:ss");
  private final Instant timestamp;

  /**
   * Constructor.
   */
  public ExprTimestampValue(String timestamp) {
    try {
      this.timestamp = LocalDateTime.parse(timestamp, FORMATTER).atZone(ZONE).toInstant();
    } catch (DateTimeParseException e) {
      throw new SemanticCheckException(String.format("timestamp:%s in unsupported format, please "
          + "use yyyy-MM-dd HH:mm:ss", timestamp));
    }

  }

  @Override
  public String value() {
    return FORMATTER.withZone(ZONE).format(timestamp.truncatedTo(ChronoUnit.SECONDS));
  }

  @Override
  public ExprType type() {
    return ExprCoreType.TIMESTAMP;
  }

  @Override
  public Instant timestampValue() {
    return timestamp;
  }

  @Override
  public String toString() {
    return String.format("TIMESTAMP '%s'", value());
  }

  @Override
  public int compare(ExprValue other) {
    return timestamp.compareTo(other.timestampValue());
  }

  @Override
  public boolean equal(ExprValue other) {
    return timestamp.equals(other.timestampValue());
  }

  @Override
  public int hashCode() {
    return Objects.hashCode(timestamp);
  }
}
