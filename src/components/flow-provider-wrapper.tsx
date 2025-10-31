"use client";

import { FlowProvider } from "@onflow/react-sdk";
import { ReactNode } from "react";
import flowJSON from "../../flow.json";

interface FlowProviderWrapperProps {
  children: ReactNode;
}

let local = true

export function FlowProviderWrapper({ children }: FlowProviderWrapperProps) {
  return (
    <FlowProvider
      config={{
        // Testnet configuration
        "accessNodeUrl": local? "http://localhost:8888": "https://rest-testnet.onflow.org",
        "discoveryWallet": local ? "http://localhost:8701/fcl/authn": "https://fcl-discovery.onflow.org/testnet/authn",
        "discoveryAuthnEndpoint": local ? "http://localhost:8701/fcl/authn" :
          "https://fcl-discovery.onflow.org/api/testnet/authn",
        "flowNetwork": local? "emulator" : "testnet",

        // App metadata
        "appDetailTitle": local? "Local Flow Emulator": "Flow React SDK Starter",
        "appDetailUrl":
          typeof window !== "undefined" ? window.location.origin : "",
        "appDetailIcon": "https://avatars.githubusercontent.com/u/62387156?v=4",
        "appDetailDescription": local? "The local testing environment for my Cadence version of the election App": 
          "A Next.js starter template for Flow blockchain applications",

        // Optional configuration
        "computeLimit": 1000,
        // Example WalletConnect project ID
        "walletconnectProjectId": "9b70cfa398b2355a5eb9b1cf99f4a981",
      }}
      flowJson={flowJSON}
    >
      {children}
    </FlowProvider>
  );
}
