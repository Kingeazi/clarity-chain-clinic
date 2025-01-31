import {
  Clarinet,
  Tx,
  Chain,
  Account,
  types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
  name: "Ensures doctor registration and verification works",
  async fn(chain: Chain, accounts: Map<string, Account>) {
    let deployer = accounts.get("deployer")!;
    let doctor = accounts.get("wallet_1")!;
    
    let block = chain.mineBlock([
      Tx.contractCall("doctors-registry", "register-doctor",
        [types.utf8("Dr. Smith"), types.ascii("MD123"), types.utf8("Cardiology")],
        doctor.address)
    ]);
    
    assertEquals(block.receipts.length, 1);
    assertEquals(block.height, 2);
    block.receipts[0].result.expectOk().expectBool(true);
  },
});
