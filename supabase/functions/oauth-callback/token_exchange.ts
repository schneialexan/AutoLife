export async function mockConnectorTokens(input: {
  connectorId: string;
  tenantId: string;
  code: string;
}): Promise<Record<string, unknown>> {
  if (input.connectorId === "mock") {
    return {
      access_token: "mock-access-token",
      refresh_token: "mock-refresh-token",
      token_type: "Bearer",
      expires_in: 3600,
      oauth_code: input.code,
      tenant_id: input.tenantId,
    };
  }
  throw new Error(`unsupported_connector:${input.connectorId}`);
}
