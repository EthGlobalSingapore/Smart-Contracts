"use client";
import { config, queryClient } from "@/config";
import { AlchemyClientState } from "@account-kit/core";
import { AlchemyAccountProvider } from "@account-kit/react";
import { QueryClientProvider } from "@tanstack/react-query";
import { PropsWithChildren, Suspense } from "react";
// import { DynamicContextProvider } from '@dynamic-labs/sdk-react-core'
// import { EthereumWalletConnectors } from '@dynamic-labs/ethereum'

export const Providers = (
  props: PropsWithChildren<{ initialState?: AlchemyClientState }>
) => {
  
  const DYNAMIC_ENVIRONMENT_ID = process.env.NEXT_PUBLIC_DYNAMIC_ENVIRONMENT_ID!


  return (
    // <DynamicContextProvider
    //     settings={{
    //       environmentId: DYNAMIC_ENVIRONMENT_ID,
    //       walletConnectors: [EthereumWalletConnectors],
    //     }}
    //   >
    <QueryClientProvider client={queryClient}>
      <AlchemyAccountProvider
        config={config}
        queryClient={queryClient}
        initialState={props.initialState}
      >
        {props.children}
      </AlchemyAccountProvider>
    </QueryClientProvider>
    // </DynamicContextProvider>
  );
};
