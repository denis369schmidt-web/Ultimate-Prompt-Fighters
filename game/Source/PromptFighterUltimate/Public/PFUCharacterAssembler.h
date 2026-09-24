#pragma once

#include "CoreMinimal.h"
#include "Components/ActorComponent.h"
#include "PFUTypes.h"
#include "PFUCharacterAssembler.generated.h"

class UStaticMeshComponent;

UCLASS(ClassGroup=(PFU), meta=(BlueprintSpawnableComponent))
class PROMPTFIGHTERULTIMATE_API UPFUCharacterAssembler : public UActorComponent
{
    GENERATED_BODY()

public:
    void AssembleFallback(const FPFUFighterProfile& Profile);

private:
    UStaticMeshComponent* AddModule(FName Name, const TCHAR* MeshPath, FVector Location, FVector Scale, FLinearColor Color);
    UPROPERTY(Transient) TArray<TObjectPtr<UStaticMeshComponent>> Modules;
};

